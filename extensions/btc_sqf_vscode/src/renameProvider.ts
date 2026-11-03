import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import { WorkspaceIndexer } from './workspaceIndexer';
import { NativeCommandsManager } from './nativeCommands';
import { CbaResolver } from './cbaResolver';
import { SyntaxClassifier, CharType } from './syntaxClassifier';
import { CustomFunctionInfo, ResolvedMacro } from './types';

interface RenameTargetLocalVar {
    kind: 'localVar';
    name: string;
    range: vscode.Range;
}

interface RenameTargetFunction {
    kind: 'function';
    info: CustomFunctionInfo;
    shortName: string;
    fullName: string;
    range: vscode.Range;
}

interface RenameTargetGlobalVar {
    kind: 'globalVar';
    macro?: ResolvedMacro;
    name: string;
    fullName?: string;
    range: vscode.Range;
}

type RenameTarget = RenameTargetLocalVar | RenameTargetFunction | RenameTargetGlobalVar;

function escapeRegExp(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export class SqfRenameProvider implements vscode.RenameProvider {
    private static KEYWORDS: Set<string> = new Set([
        'if', 'then', 'else', 'while', 'do', 'waituntil', 'exitwith',
        'for', 'from', 'to', 'step', 'foreach', 'count', 'switch', 'case', 'default',
        'try', 'catch', 'throw', 'with', 'private', 'params', 'return', 'assert'
    ]);

    private static MAGIC_VARIABLES: Set<string> = new Set([
        '_this', '_x', '_y', '_foreachindex', '_self', '_exception',
        '_thisargs', '_thisevent', '_thiseventhandler', '_thisscript',
        '_fnc_scriptname', '_fnc_scriptnameparent', '_fnc_scriptmap',
        'this', 'thislist', 'thistrigger', 'thisactivator'
    ]);

    constructor(
        private indexer: WorkspaceIndexer,
        private nativeCommands: NativeCommandsManager
    ) {}

    public prepareRename(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.Range | { range: vscode.Range; placeholder: string }> {
        const target = this.resolveRenameTarget(document, position);
        let placeholder = '';

        if (target.kind === 'localVar') {
            placeholder = target.name;
        } else if (target.kind === 'function') {
            placeholder = target.shortName;
        } else if (target.kind === 'globalVar') {
            placeholder = target.name;
        }

        return {
            range: target.range,
            placeholder
        };
    }

    public async provideRenameEdits(
        document: vscode.TextDocument,
        position: vscode.Position,
        newName: string,
        token: vscode.CancellationToken
    ): Promise<vscode.WorkspaceEdit | undefined> {
        let trimmedNewName = newName.trim();
        if (!trimmedNewName || !/^[_a-zA-Z0-9]+$/.test(trimmedNewName)) {
            throw new Error(`'${newName}' is not a valid SQF identifier.`);
        }

        const target = this.resolveRenameTarget(document, position);
        const edit = new vscode.WorkspaceEdit();

        if (target.kind === 'localVar') {
            // Local variable must start with '_'
            if (!trimmedNewName.startsWith('_')) {
                trimmedNewName = '_' + trimmedNewName;
            }
            this.renameLocalVariable(document, target.name, trimmedNewName, edit);
        } else if (target.kind === 'function') {
            await this.renameFunction(document, target, trimmedNewName, edit);
        } else if (target.kind === 'globalVar') {
            await this.renameGlobalVariable(document, target, trimmedNewName, edit);
        }

        return edit;
    }

    /**
     * Identifies the symbol under the cursor and its refactoring category.
     */
    private resolveRenameTarget(document: vscode.TextDocument, position: vscode.Position): RenameTarget {
        const classified = SyntaxClassifier.getClassified(document);
        const offset = document.offsetAt(position);

        if (classified.isInsideComment(offset)) {
            throw new Error('Cannot rename a symbol inside a comment.');
        }

        const lineText = document.lineAt(position.line).text;
        const charIndex = position.character;

        // 1. Check for CBA macro invocation under cursor
        const macro = CbaResolver.findMacroAtPosition(lineText, charIndex, document.uri.fsPath);
        if (macro) {
            const macroRange = new vscode.Range(
                position.line,
                macro.range.startChar,
                position.line,
                macro.range.endChar
            );

            if (macro.type === 'FUNC' || macro.type === 'QFUNC' || macro.type === 'EFUNC' || macro.type === 'QEFUNC' || macro.type === 'RAW_FUNC') {
                const funcInfo = this.indexer.findFunction(macro.component, macro.name, macro.fullName) || {
                    fullName: macro.fullName,
                    shortName: macro.name,
                    component: macro.component,
                    prefix: macro.prefix,
                    filePath: '',
                    description: '',
                    parameters: [],
                    returns: ''
                };

                return {
                    kind: 'function',
                    info: funcInfo,
                    shortName: funcInfo.shortName || macro.name,
                    fullName: funcInfo.fullName || macro.fullName,
                    range: macroRange
                };
            }

            if (macro.type === 'GVAR' || macro.type === 'QGVAR' || macro.type === 'EGVAR' || macro.type === 'QEGVAR') {
                return {
                    kind: 'globalVar',
                    macro,
                    name: macro.name,
                    fullName: macro.fullName,
                    range: macroRange
                };
            }
        }

        // 2. Check word under cursor
        const wordRange = document.getWordRangeAtPosition(position, /[_a-zA-Z0-9]+/);
        if (!wordRange) {
            throw new Error('No symbol found under cursor to rename.');
        }

        const word = document.getText(wordRange);

        if (classified.isInsideString(offset)) {
            // Only allow renaming inside strings if it is a quoted variable name or macro argument
            if (!word.startsWith('_')) {
                throw new Error('Cannot rename arbitrary string literal.');
            }
        }

        // Protected symbol validation
        if (this.nativeCommands.getCommand(word)) {
            throw new Error(`Cannot rename native Arma 3 command '${word}'.`);
        }
        if (SqfRenameProvider.KEYWORDS.has(word.toLowerCase())) {
            throw new Error(`Cannot rename SQF keyword '${word}'.`);
        }
        if (SqfRenameProvider.MAGIC_VARIABLES.has(word.toLowerCase())) {
            throw new Error(`Cannot rename engine magic variable '${word}'.`);
        }
        if (word.startsWith('__')) {
            throw new Error(`Cannot rename preprocessor macro '${word}'.`);
        }

        // 3. Check if word is a custom function in workspace indexer
        const customFunc = this.indexer.findFunction(undefined, word, word);
        if (customFunc) {
            return {
                kind: 'function',
                info: customFunc,
                shortName: customFunc.shortName,
                fullName: customFunc.fullName,
                range: wordRange
            };
        }

        // 4. Check if word has _fnc_ pattern (e.g. btc_cas_fnc_dive)
        if (word.includes('_fnc_')) {
            const parts = word.split('_fnc_');
            const shortName = parts[1];
            const found = this.indexer.findFunction(undefined, shortName, word) || {
                fullName: word,
                shortName,
                component: '',
                prefix: '',
                filePath: '',
                description: '',
                parameters: [],
                returns: ''
            };
            return {
                kind: 'function',
                info: found,
                shortName,
                fullName: word,
                range: wordRange
            };
        }

        // 5. Local variable
        if (word.startsWith('_')) {
            return {
                kind: 'localVar',
                name: word,
                range: wordRange
            };
        }

        // 6. Global variable
        return {
            kind: 'globalVar',
            name: word,
            range: wordRange
        };
    }

    /**
     * Renames a local variable across the current file.
     */
    private renameLocalVariable(
        document: vscode.TextDocument,
        oldName: string,
        newName: string,
        edit: vscode.WorkspaceEdit
    ): void {
        const classified = SyntaxClassifier.getClassified(document);
        const regex = new RegExp(`\\b${escapeRegExp(oldName)}\\b`, 'gi');

        for (let lineIdx = 0; lineIdx < document.lineCount; lineIdx++) {
            const line = document.lineAt(lineIdx);
            const lineText = line.text;
            const lineOffset = document.offsetAt(new vscode.Position(lineIdx, 0));
            let match: RegExpExecArray | null;
            regex.lastIndex = 0;

            while ((match = regex.exec(lineText)) !== null) {
                const charOffset = lineOffset + match.index;
                const charType = classified.charTypes[charOffset];

                // Skip comments
                if (charType === CharType.LineComment || charType === CharType.BlockComment) {
                    continue;
                }

                // If code, replace
                if (charType === CharType.Code) {
                    const range = new vscode.Range(
                        lineIdx,
                        match.index,
                        lineIdx,
                        match.index + match[0].length
                    );
                    edit.replace(document.uri, range, newName);
                } else if (charType === CharType.String) {
                    // Check if directly quoted variable declaration, e.g. params ["_var", ...] or for "_var" from ...
                    const before = lineText.slice(0, match.index).trim();
                    const after = lineText.slice(match.index + match[0].length).trim();
                    const isDirectlyQuoted = (before.endsWith('"') && after.startsWith('"')) ||
                                             (before.endsWith("'") && after.startsWith("'"));
                    if (isDirectlyQuoted) {
                        const range = new vscode.Range(
                            lineIdx,
                            match.index,
                            lineIdx,
                            match.index + match[0].length
                        );
                        edit.replace(document.uri, range, newName);
                    }
                }
            }
        }
    }

    /**
     * Renames a custom function across the workspace (calls, headers, XEH_PREP, and file).
     */
    private async renameFunction(
        document: vscode.TextDocument,
        target: RenameTargetFunction,
        newNameInput: string,
        edit: vscode.WorkspaceEdit
    ): Promise<void> {
        const info = target.info;

        // Clean user input: strip fnc_ or prefix_comp_fnc_
        let cleanShort = newNameInput.replace(/^fnc_/, '');
        if (info.component) {
            cleanShort = cleanShort.replace(new RegExp(`^${escapeRegExp(info.component)}_fnc_`, 'i'), '');
        }
        if (info.prefix && info.component) {
            cleanShort = cleanShort.replace(new RegExp(`^${escapeRegExp(info.prefix)}_${escapeRegExp(info.component)}_fnc_`, 'i'), '');
        }

        const oldShortName = target.shortName;
        const newShortName = cleanShort;
        const oldFullName = info.fullName;
        const newFullName = info.prefix && info.component
            ? `${info.prefix}_${info.component}_fnc_${newShortName}`
            : oldFullName.replace(new RegExp(`_fnc_${escapeRegExp(oldShortName)}$`, 'i'), `_fnc_${newShortName}`);

        // Extract folder and file basename if short name is prefixed by a folder (e.g. vehicle_dive)
        let oldFolder = '';
        let oldFileBase = oldShortName;
        let newFileBase = newShortName;

        const underIdx = oldShortName.indexOf('_');
        if (underIdx !== -1) {
            const candidateFolder = oldShortName.slice(0, underIdx);
            const candidateBase = oldShortName.slice(underIdx + 1);
            if (info.filePath && info.filePath.toLowerCase().includes(path.sep + candidateFolder.toLowerCase() + path.sep)) {
                oldFolder = candidateFolder;
                oldFileBase = candidateBase;
                if (newShortName.startsWith(oldFolder + '_')) {
                    newFileBase = newShortName.slice(oldFolder.length + 1);
                }
            }
        }

        // Short prefix alias (e.g. btc_cas_fnc_xxx vs btc_toolchain_cas_fnc_xxx)
        const oldShortAlias = info.component ? `btc_${info.component}_fnc_${oldShortName}` : '';
        const newShortAlias = info.component ? `btc_${info.component}_fnc_${newShortName}` : '';

        // Find all code files across the workspace
        const files = await vscode.workspace.findFiles('**/*.{sqf,hpp,inc,cpp}', '**/node_modules/**');

        for (const uri of files) {
            const doc = await vscode.workspace.openTextDocument(uri);
            const content = doc.getText();

            // Quick check if file mentions any variant
            if (!content.includes(oldShortName) &&
                !content.includes(oldFileBase) &&
                !content.includes(oldFullName) &&
                (!oldShortAlias || !content.includes(oldShortAlias))) {
                continue;
            }

            const classified = SyntaxClassifier.getClassified(doc);
            const ctx = CbaResolver.resolveContext(uri.fsPath);
            const isSameComponent = Boolean(info.component && ctx.component.toLowerCase() === info.component.toLowerCase());

            for (let lineIdx = 0; lineIdx < doc.lineCount; lineIdx++) {
                const line = doc.lineAt(lineIdx);
                const lineText = line.text;
                const lineOffset = doc.offsetAt(new vscode.Position(lineIdx, 0));

                // 1. Same-component macro calls: FUNC(oldShortName), QFUNC(oldShortName), LINKFUNC(oldShortName)
                if (isSameComponent) {
                    const funcMacroRegex = new RegExp(`\\b(Q?FUNC|LINKFUNC|DFUNC)\\s*\\(\\s*(${escapeRegExp(oldShortName)})\\s*\\)`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = funcMacroRegex.exec(lineText)) !== null) {
                        const nameStart = m.index + m[0].lastIndexOf(m[2]);
                        const charOffset = lineOffset + nameStart;
                        if (!classified.isInsideComment(charOffset)) {
                            const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[2].length);
                            edit.replace(uri, range, newShortName);
                        }
                    }
                }

                // 2. Cross-component macro calls: EFUNC(comp, oldShortName), QEFUNC(comp, oldShortName)
                if (info.component) {
                    const efuncRegex = new RegExp(`\\b(Q?EFUNC)\\s*\\(\\s*${escapeRegExp(info.component)}\\s*,\\s*(${escapeRegExp(oldShortName)})\\s*\\)`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = efuncRegex.exec(lineText)) !== null) {
                        const nameStart = m.index + m[0].lastIndexOf(m[2]);
                        const charOffset = lineOffset + nameStart;
                        if (!classified.isInsideComment(charOffset)) {
                            const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[2].length);
                            edit.replace(uri, range, newShortName);
                        }
                    }
                }

                // 3. XEH_PREP.hpp: PREP_FOLDER(folder, fileBase) or PREP(fileBase)
                if (uri.fsPath.endsWith('XEH_PREP.hpp')) {
                    if (oldFolder) {
                        const prepFolderRegex = new RegExp(`\\bPREP_FOLDER\\s*\\(\\s*${escapeRegExp(oldFolder)}\\s*,\\s*(${escapeRegExp(oldFileBase)})\\s*\\)`, 'gi');
                        let m: RegExpExecArray | null;
                        while ((m = prepFolderRegex.exec(lineText)) !== null) {
                            const nameStart = m.index + m[0].lastIndexOf(m[1]);
                            const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[1].length);
                            edit.replace(uri, range, newFileBase);
                        }
                    }

                    const prepRegex = new RegExp(`\\bPREP\\s*\\(\\s*(${escapeRegExp(oldFileBase)})\\s*\\)`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = prepRegex.exec(lineText)) !== null) {
                        const nameStart = m.index + m[0].lastIndexOf(m[1]);
                        const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[1].length);
                        edit.replace(uri, range, newFileBase);
                    }
                }

                // 4. Raw function full names: oldFullName or oldShortAlias
                const rawRegex = new RegExp(`\\b(${escapeRegExp(oldFullName)}${oldShortAlias ? '|' + escapeRegExp(oldShortAlias) : ''})\\b`, 'gi');
                let m: RegExpExecArray | null;
                while ((m = rawRegex.exec(lineText)) !== null) {
                    const charOffset = lineOffset + m.index;
                    if (!classified.isInsideComment(charOffset) || lineText.includes('Function:')) {
                        const matched = m[1];
                        const replacement = oldShortAlias && matched.toLowerCase() === oldShortAlias.toLowerCase()
                            ? newShortAlias
                            : newFullName;
                        const range = new vscode.Range(lineIdx, m.index, lineIdx, m.index + matched.length);
                        edit.replace(uri, range, replacement);
                    }
                }
            }
        }

        // 5. Rename function file on disk if matching standard fnc_<name>.sqf naming
        if (info.filePath && fs.existsSync(info.filePath)) {
            const dir = path.dirname(info.filePath);
            const currentFileName = path.basename(info.filePath);
            const expectedOldName = `fnc_${oldFileBase}.sqf`;
            if (currentFileName.toLowerCase() === expectedOldName.toLowerCase()) {
                const newFilePath = path.join(dir, `fnc_${newFileBase}.sqf`);
                edit.renameFile(vscode.Uri.file(info.filePath), vscode.Uri.file(newFilePath), {
                    overwrite: false,
                    ignoreIfExists: true
                });
            }
        }
    }

    /**
     * Renames a global variable across the workspace.
     */
    private async renameGlobalVariable(
        document: vscode.TextDocument,
        target: RenameTargetGlobalVar,
        newVarName: string,
        edit: vscode.WorkspaceEdit
    ): Promise<void> {
        const oldVarName = target.name;
        const comp = target.macro?.component || '';
        const prefix = target.macro?.prefix || CbaResolver.resolveContext(document.uri.fsPath).prefix;
        const oldFullName = target.fullName || (comp ? `${prefix}_${comp}_${oldVarName}` : oldVarName);
        const newFullName = comp ? `${prefix}_${comp}_${newVarName}` : newVarName;

        const oldShortAlias = comp ? `btc_${comp}_${oldVarName}` : '';
        const newShortAlias = comp ? `btc_${comp}_${newVarName}` : '';

        const files = await vscode.workspace.findFiles('**/*.{sqf,hpp,inc,cpp}', '**/node_modules/**');

        for (const uri of files) {
            const doc = await vscode.workspace.openTextDocument(uri);
            const content = doc.getText();

            if (!content.includes(oldVarName) &&
                !content.includes(oldFullName) &&
                (!oldShortAlias || !content.includes(oldShortAlias))) {
                continue;
            }

            const classified = SyntaxClassifier.getClassified(doc);
            const ctx = CbaResolver.resolveContext(uri.fsPath);
            const isSameComponent = Boolean(comp && ctx.component.toLowerCase() === comp.toLowerCase());

            for (let lineIdx = 0; lineIdx < doc.lineCount; lineIdx++) {
                const line = doc.lineAt(lineIdx);
                const lineText = line.text;
                const lineOffset = doc.offsetAt(new vscode.Position(lineIdx, 0));

                // 1. Same-component GVAR(var) or QGVAR(var)
                if (isSameComponent) {
                    const gvarRegex = new RegExp(`\\b(Q?GVAR)\\s*\\(\\s*(${escapeRegExp(oldVarName)})\\s*\\)`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = gvarRegex.exec(lineText)) !== null) {
                        const nameStart = m.index + m[0].lastIndexOf(m[2]);
                        const charOffset = lineOffset + nameStart;
                        if (!classified.isInsideComment(charOffset)) {
                            const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[2].length);
                            edit.replace(uri, range, newVarName);
                        }
                    }
                }

                // 2. Cross-component EGVAR(comp, var) or QEGVAR(comp, var)
                if (comp) {
                    const egvarRegex = new RegExp(`\\b(Q?EGVAR)\\s*\\(\\s*${escapeRegExp(comp)}\\s*,\\s*(${escapeRegExp(oldVarName)})\\s*\\)`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = egvarRegex.exec(lineText)) !== null) {
                        const nameStart = m.index + m[0].lastIndexOf(m[2]);
                        const charOffset = lineOffset + nameStart;
                        if (!classified.isInsideComment(charOffset)) {
                            const range = new vscode.Range(lineIdx, nameStart, lineIdx, nameStart + m[2].length);
                            edit.replace(uri, range, newVarName);
                        }
                    }
                }

                // 3. Raw global variable full name: oldFullName or oldShortAlias
                if (comp) {
                    const rawRegex = new RegExp(`\\b(${escapeRegExp(oldFullName)}${oldShortAlias ? '|' + escapeRegExp(oldShortAlias) : ''})\\b`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = rawRegex.exec(lineText)) !== null) {
                        const charOffset = lineOffset + m.index;
                        if (!classified.isInsideComment(charOffset)) {
                            const matched = m[1];
                            const replacement = oldShortAlias && matched.toLowerCase() === oldShortAlias.toLowerCase()
                                ? newShortAlias
                                : newFullName;
                            const range = new vscode.Range(lineIdx, m.index, lineIdx, m.index + matched.length);
                            edit.replace(uri, range, replacement);
                        }
                    }
                } else {
                    // Standalone global variable without CBA component
                    const rawRegex = new RegExp(`\\b${escapeRegExp(oldVarName)}\\b`, 'gi');
                    let m: RegExpExecArray | null;
                    while ((m = rawRegex.exec(lineText)) !== null) {
                        const charOffset = lineOffset + m.index;
                        if (!classified.isInsideComment(charOffset)) {
                            const range = new vscode.Range(lineIdx, m.index, lineIdx, m.index + m[0].length);
                            edit.replace(uri, range, newVarName);
                        }
                    }
                }
            }
        }
    }
}
