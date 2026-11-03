import * as vscode from 'vscode';
import { SyntaxClassifier, CharType } from './syntaxClassifier';

const tokenTypes = ['variable', 'parameter', 'function', 'macro', 'enumMember', 'keyword', 'operator', 'namespace'];
const tokenModifiers = ['declaration', 'readonly', 'static', 'local', 'defaultLibrary'];

export const semanticLegend = new vscode.SemanticTokensLegend(tokenTypes, tokenModifiers);

export class SqfSemanticTokensProvider implements vscode.DocumentSemanticTokensProvider {
    private static MACRO_REGEX = /\b(Q?E?FUNC|Q?E?GVAR|QUOTE|DOUBLES|TRIPLES|PREP|PREP_FOLDER|ARR_\d+|PATHTOF|PATHTOF_SYS|PATHTO_SYS|LINKFUNC|INFO|LOG|WARNING|ERROR)\s*\(/g;
    private static ALL_CAPS_DEFINE_REGEX = /\b[A-Z][A-Z0-9_]{1,}\b/g;
    private static LOCAL_VAR_REGEX = /\b_[a-zA-Z0-9_]+\b/g;
    private static FNC_REGEX = /\b[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+\b/g;
    private static MAGIC_VAR_SET = new Set([
        '_this',
        '_x',
        '_y',
        '_foreachindex',
        '_self',
        '_exception',
        '_thisargs',
        '_thisevent',
        '_thiseventhandler',
        '_thisscript',
        '_fnc_scriptname',
        '_fnc_scriptnameparent',
        '_fnc_scriptmap',
        'this',
        'thislist',
        'thistrigger',
        'thisactivator'
    ]);

    public provideDocumentSemanticTokens(
        document: vscode.TextDocument
    ): vscode.ProviderResult<vscode.SemanticTokens> {
        const builder = new vscode.SemanticTokensBuilder(semanticLegend);

        const macroTypeIdx = tokenTypes.indexOf('macro');
        const paramTypeIdx = tokenTypes.indexOf('parameter');
        const varTypeIdx = tokenTypes.indexOf('variable');
        const fncTypeIdx = tokenTypes.indexOf('function');
        const enumMemberTypeIdx = tokenTypes.indexOf('enumMember');
        const keywordTypeIdx = tokenTypes.indexOf('keyword');
        const operatorTypeIdx = tokenTypes.indexOf('operator');
        const namespaceTypeIdx = tokenTypes.indexOf('namespace');

        const localModBit = 1 << tokenModifiers.indexOf('local');
        const readonlyModBit = 1 << tokenModifiers.indexOf('readonly');
        const staticModBit = 1 << tokenModifiers.indexOf('static');
        const defaultLibraryModBit = 1 << tokenModifiers.indexOf('defaultLibrary');
        const defineModBits = readonlyModBit | staticModBit;
        const magicVarModBits = defaultLibraryModBit | readonlyModBit;

        const classified = SyntaxClassifier.getClassified(document);

        for (let lineIdx = 0; lineIdx < document.lineCount; lineIdx++) {
            const cleanLine = classified.getLineMasked(lineIdx);
            const trimmed = cleanLine.trim();
            if (!trimmed || trimmed.startsWith('#')) {
                continue;
            }

            // Keep track of ranges already tokenized to avoid overlap
            const tokenized = new Set<string>();
            const lineStartOffset = document.offsetAt(new vscode.Position(lineIdx, 0));

            // Exclude anything that is not code (comments, block comments, strings)
            for (let c = 0; c < cleanLine.length; c++) {
                if (classified.charTypes[lineStartOffset + c] !== CharType.Code) {
                    tokenized.add(`${c}`);
                }
            }

            // 1. CBA Macro invocations and their arguments
            let match: RegExpExecArray | null;
            const macroCallRegex = /\b(Q?E?FUNC|Q?E?GVAR|QUOTE|DOUBLES|TRIPLES|PREP|PREP_FOLDER|ARR_\d+|PATHTOF|PATHTOF_SYS|PATHTO_SYS|LINKFUNC|INFO|LOG|WARNING|ERROR)\s*\(([^)]*)\)/g;

            while ((match = macroCallRegex.exec(cleanLine)) !== null) {
                const macroName = match[1];
                const macroStart = match.index;
                builder.push(lineIdx, macroStart, macroName.length, macroTypeIdx, 0);
                for (let c = macroStart; c < macroStart + macroName.length; c++) {
                    tokenized.add(`${c}`);
                }

                // Arguments inside parenthesis
                const argsText = match[2];
                const argsStart = match.index + match[0].indexOf('(') + 1;
                const argTokenRegex = /\b([a-zA-Z0-9_]+)\b/g;
                let argMatch: RegExpExecArray | null;

                while ((argMatch = argTokenRegex.exec(argsText)) !== null) {
                    const argName = argMatch[1];
                    const argChar = argsStart + argMatch.index;

                    // If it's a built-in preprocessor macro (e.g. __FILE_NAME__, __LINE__)
                    if (argName.startsWith('__')) {
                        builder.push(lineIdx, argChar, argName.length, macroTypeIdx, 0);
                    } else if (SqfSemanticTokensProvider.MAGIC_VAR_SET.has(argName.toLowerCase())) {
                        builder.push(lineIdx, argChar, argName.length, varTypeIdx, magicVarModBits);
                    } else if (argName.startsWith('_')) {
                        // Local variable inside macro
                        builder.push(lineIdx, argChar, argName.length, varTypeIdx, localModBit);
                    } else if (/^[A-Z][A-Z0-9_]{1,}$/.test(argName)) {
                        // All-caps constant/define operand inside macro (e.g. LOGS, QCOMPONENT) -> enumMember (cyan #4FC1FF)
                        builder.push(lineIdx, argChar, argName.length, enumMemberTypeIdx, readonlyModBit);
                    } else {
                        // Macro parameter argument operand (e.g. tools, debug, table) -> enumMember (cyan #4FC1FF)
                        builder.push(lineIdx, argChar, argName.length, enumMemberTypeIdx, 0);
                    }

                    for (let c = argChar; c < argChar + argName.length; c++) {
                        tokenized.add(`${c}`);
                    }
                }
            }

            // 2. Built-in PreProcessor Macros (e.g. __FILE_NAME__, __FILE__, __LINE__, etc.) -> macro (purple #BD63C5)
            const builtinMacroRegex = /\b__(?:A3_DEBUG|A3_DIAG|ARMA|ARMA3|COUNTER|COUNTER_RESET|DATE_ARR|DATE_STR|DATE_STR_ISO8601|DAY|FILE(?:_(?:NAME|SHORT))?|GAME_BUILD|GAME_VER|GAME_VER_MAJ|GAME_VER_MIN|LINE|MONTH|RAND_(?:U)?INT(?:8|16|32|64)|TIME|TIME_UTC|TIMESTAMP_UTC|YEAR)__\b|\b__has_include\b|\b__(?:EVAL|EXEC)\b/g;
            while ((match = builtinMacroRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[0].length, macroTypeIdx, 0);
                for (let c = match.index; c < match.index + match[0].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 3. Custom function names (e.g. btc_cas_fnc_list_attributeSave)
            const fncRegex = /\b([a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+)\b/g;
            while ((match = fncRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[1].length, fncTypeIdx, 0);
                for (let c = match.index; c < match.index + match[1].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 4. Native functions: isEqual*, isNotEqual*, disableSerialization, compile, compileFinal (qualify as function -> yellow #DCDCAA)
            const nativeFuncRegex = /\b(?i:isEqualTo|isNotEqualTo|isEqualType|isEqualTypeAll|isEqualTypeAny|isEqualTypeArray|isEqualTypeParams|isEqualRef|isNotEqualRef|disableSerialization|compile|compileFinal)\b/g;
            while ((match = nativeFuncRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[0].length, fncTypeIdx, 0);
                for (let c = match.index; c < match.index + match[0].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 5. Namespaces (missionNamespace, uiNamespace, parsingNamespace, profileNamespace, currentNamespace, etc.) -> namespace (teal #4EC9B0)
            const namespaceRegex = /\b(?i:missionNamespace|uiNamespace|parsingNamespace|profileNamespace|missionProfileNamespace|currentNamespace|localNamespace|serverNamespace)\b/g;
            while ((match = namespaceRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[0].length, namespaceTypeIdx, 0);
                for (let c = match.index; c < match.index + match[0].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 6. Word operators: and, or, not, in (qualify as keyword -> purple #C586C0)
            const wordOpRegex = /\b(?i:and|or|not|in)\b/g;
            while ((match = wordOpRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[0].length, keywordTypeIdx, 0);
                for (let c = match.index; c < match.index + match[0].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 7. Magic variables (e.g. _this, _x, _y, _forEachIndex, _self, _exception, this, thisList, thisTrigger, etc.)
            // Emitted with defaultLibrary & readonly modifiers -> maps to variable.defaultLibrary (blue #569CD6 in dark themes)
            const magicVarRegex = /\b(_(?:this(?:Args|Event|EventHandler|Script)?|forEachIndex|fnc_script(?:Name(?:Parent)?|Map)|exception|self|x|y)|this(?:Activator|List|Trigger)?)\b/gi;
            while ((match = magicVarRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                builder.push(lineIdx, match.index, match[0].length, varTypeIdx, magicVarModBits);
                for (let c = match.index; c < match.index + match[0].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 8. Local variables (starting with single '_', not double '__') -> variable (light blue #9CDCFE)
            const localVarRegex = /\b(_[a-zA-Z0-9][a-zA-Z0-9_]*)\b/g;
            while ((match = localVarRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                if (match[1].startsWith('__')) continue;
                builder.push(lineIdx, match.index, match[1].length, varTypeIdx, localModBit);
                for (let c = match.index; c < match.index + match[1].length; c++) {
                    tokenized.add(`${c}`);
                }
            }

            // 9. Defines / Constants in ALL_CAPS (e.g. LIST_1, IDC_DISPLAY3DENEDITATTRIBUTES_VALUE, LOGS, QCOMPONENT)
            // Color as enumMember (cyan #4FC1FF) so operands that are defines are distinct from local variables
            const defineRegex = /\b([A-Z][A-Z0-9_]{1,})\b/g;
            while ((match = defineRegex.exec(cleanLine)) !== null) {
                if (tokenized.has(`${match.index}`)) continue;
                // Exclude common boolean/null constants or word operators that have their own syntax token
                const w = match[1];
                if (['TRUE', 'FALSE', 'NIL', 'NULL', 'AND', 'OR', 'NOT', 'IN'].includes(w)) continue;
                builder.push(lineIdx, match.index, w.length, enumMemberTypeIdx, readonlyModBit);
                for (let c = match.index; c < match.index + w.length; c++) {
                    tokenized.add(`${c}`);
                }
            }
        }

        return builder.build();
    }
}

