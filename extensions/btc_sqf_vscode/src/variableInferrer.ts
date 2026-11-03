import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { InferredVariable, CustomFunctionInfo } from './types';
import { NativeCommandsManager } from './nativeCommands';
import { WorkspaceIndexer } from './workspaceIndexer';
import { CbaResolver } from './cbaResolver';
import { SqfDocParser } from './docParser';
import { SyntaxClassifier, ClassifiedDocument } from './syntaxClassifier';

export class VariableTypeInferrer {
    private static defaultIndexer?: WorkspaceIndexer;

    public static setIndexer(indexer: WorkspaceIndexer) {
        this.defaultIndexer = indexer;
    }

    public static getIndexer(): WorkspaceIndexer | undefined {
        return this.defaultIndexer;
    }
    private static KEYWORDS: Set<string> = new Set([
        'private', 'params', 'if', 'then', 'else', 'while', 'do',
        'waituntil', 'exitwith', 'return', 'assert', 'case', 'default',
        'try', 'catch', 'throw', 'for', 'from', 'to', 'step', 'with'
    ]);

    private static KNOWN_CONSTRUCTORS: Record<string, string> = {
        'controlnull': 'Control',
        'displaynull': 'Display',
        'objnull': 'Object',
        'grpnull': 'Group',
        'locationnull': 'Location',
        'tasknull': 'Task',
        'confignull': 'Config',
        'player': 'Object',
        'cursorobject': 'Object',
        'cursortarget': 'Object',
        'cameraon': 'Object',
        'configfile': 'Config',
        'missionconfigfile': 'Config',
        'campaignconfigfile': 'Config',
        'createhashmap': 'HashMap',
        'createhashmapfromarray': 'HashMap'
    };

    private static KNOWN_COMMAND_ARRAY_ELEMENT_TYPES: Record<string, string> = {
        // Objects
        'nearentities': 'Object',
        'nearobjects': 'Object',
        'nearobjectsready': 'Object',
        'nearestobjects': 'Object',
        'nearroads': 'Object',
        'allunits': 'Object',
        'allplayers': 'Object',
        'allunitsuav': 'Object',
        'allcurators': 'Object',
        'allmines': 'Object',
        'alldead': 'Object',
        'allmissionobjects': 'Object',
        'synchronizedobjects': 'Object',
        'units': 'Object',
        'vehicles': 'Object',
        'crew': 'Object',
        'assignedcargo': 'Object',
        'playableunits': 'Object',
        'switchableunits': 'Object',
        'agents': 'Object',
        'lineintersectsobjs': 'Object',
        'lineintersectswith': 'Object',
        'entities': 'Object',
        'objects': 'Object',

        // Groups
        'allgroups': 'Group',
        'groups': 'Group',

        // Waypoints
        'waypoints': 'Waypoint',

        // Configs
        'configclasses': 'Config',
        'configproperties': 'Config',

        // Strings
        'allmapmarkers': 'String',
        'allvariables': 'String',
        'allcustomsoundcontrollers': 'String',
        'weapons': 'String',
        'magazines': 'String',
        'items': 'String',
        'assigneditems': 'String'
    };

    private static KNOWN_FUNCTION_RETURNS: Record<string, string> = {
        // BIS array functions
        'bis_fnc_sortby': 'Array',
        'bis_fnc_returnparents': 'Array',
        'bis_fnc_allturrets': 'Array',
        'bis_fnc_allunits': 'Array',
        'bis_fnc_allplayers': 'Array',
        'bis_fnc_allcurators': 'Array',
        'bis_fnc_listplayers': 'Array',
        'bis_fnc_getvirtualweaponcargo': 'Array',
        'bis_fnc_getvirtualitemcargo': 'Array',
        'bis_fnc_getvirtualmagazinecargo': 'Array',
        'bis_fnc_getvirtualbackpackcargo': 'Array',
        'bis_fnc_configsentry': 'Array',
        'bis_fnc_subselect': 'Array',
        'bis_fnc_arraypush': 'Number',
        'bis_fnc_arraypop': 'Any',
        'bis_fnc_arraypushstack': 'Array',
        'bis_fnc_greatestnum': 'Number',
        'bis_fnc_lowestnum': 'Number',

        // BIS scalar/number functions
        'bis_fnc_admin': 'Number',
        'bis_fnc_rounddir': 'Number',
        'bis_fnc_dirto': 'Number',
        'bis_fnc_distance2d': 'Number',
        'bis_fnc_distance2dsqr': 'Number',
        'bis_fnc_getparamvalue': 'Number',
        'bis_fnc_parsenumber': 'Number',

        // BIS boolean functions
        'bis_fnc_iscurator': 'Boolean',
        'bis_fnc_areequal': 'Boolean',
        'bis_fnc_intrigger': 'Boolean',
        'bis_fnc_instring': 'Boolean',

        // BIS string functions
        'bis_fnc_param': 'Any',
        'bis_fnc_filterstring': 'String',

        // BIS config functions
        'bis_fnc_loadclass': 'Config',
        'bis_fnc_returnconfigentry': 'Any',

        // CBA functions
        'cba_fnc_players': 'Array',
        'cba_fnc_currentweapon': 'String',
        'cba_fnc_getturret': 'Array',
        'cba_fnc_addperframehandler': 'Number',
        'cba_fnc_addeventhandler': 'Number',
        'cba_fnc_hashcreate': 'Array',
        'cba_fnc_getarg': 'Any'
    };

    /**
     * Infer all local variables defined in the document up to maxLine (or entire document if undefined).
     */
    public static inferDocumentVariables(
        document: vscode.TextDocument,
        nativeCommands?: NativeCommandsManager,
        maxLine?: number,
        indexer?: WorkspaceIndexer
    ): Map<string, InferredVariable> {
        const result = new Map<string, InferredVariable>();
        const endLine = maxLine !== undefined ? Math.min(maxLine, document.lineCount - 1) : document.lineCount - 1;
        const activeIndexer = indexer || this.defaultIndexer;
        const filePath = document.uri ? document.uri.fsPath : undefined;
        const classified = SyntaxClassifier.getClassified(document);

        // 1. Scan for params [ ... ] (excluding comments and strings)
        this.parseAllParams(classified.maskedComments, result, classified, { maxLine: endLine });

        // Track active scopes for type narrowing
        const scopeStack: Array<{ depth: number; saved: Map<string, InferredVariable | undefined> }> = [];
        let currentDepth = 0;

        // 2. Scan line by line for assignments, loops, and type narrowing
        for (let lineIdx = 0; lineIdx <= endLine; lineIdx++) {
            const cleanLineCommentsOnly = classified.getLineMaskedCommentsOnly(lineIdx).trim();
            if (!cleanLineCommentsOnly || cleanLineCommentsOnly.startsWith('#')) {
                continue;
            }

            // Check if this line introduces type narrowing before an opening brace
            const narrowings = this.detectTypeNarrowing(cleanLineCommentsOnly);

            // Track block brace changes on this line
            const maskedCodeLine = classified.lineMaskedCommentsAndStrings[lineIdx] ?? '';
            for (let cIdx = 0; cIdx < maskedCodeLine.length; cIdx++) {
                const ch = maskedCodeLine[cIdx];
                if (ch === '{') {
                    currentDepth++;
                    const saved = new Map<string, InferredVariable | undefined>();
                    if (narrowings.length > 0) {
                        for (const n of narrowings) {
                            const existing = result.get(n.varName.toLowerCase());
                            saved.set(n.varName.toLowerCase(), existing ? { ...existing } : undefined);
                            result.set(n.varName.toLowerCase(), {
                                name: n.varName,
                                type: n.narrowedType,
                                line: lineIdx,
                                declarationText: cleanLineCommentsOnly,
                                isParameter: existing?.isParameter,
                                depth: currentDepth
                            });
                        }
                    }
                    scopeStack.push({ depth: currentDepth, saved });
                } else if (ch === '}') {
                    if (scopeStack.length > 0) {
                        const top = scopeStack.pop()!;
                        for (const [k, v] of top.saved) {
                            if (v !== undefined) {
                                result.set(k, v);
                            } else {
                                result.delete(k);
                            }
                        }
                    }
                    currentDepth = Math.max(0, currentDepth - 1);
                }
            }

            // Check for 'for "_i" from ...'
            const forMatch = cleanLineCommentsOnly.match(/\bfor\s+["'](_[a-zA-Z0-9_]+)["']\s+from\b/i);
            if (forMatch) {
                const varName = forMatch[1];
                if (!result.has(varName.toLowerCase())) {
                    result.set(varName.toLowerCase(), {
                        name: varName,
                        type: 'Number',
                        line: lineIdx,
                        declarationText: document.lineAt(lineIdx).text.trim(),
                        depth: currentDepth
                    });
                }
            }

            // Check for assignments on this line: [private] _var = <expression>;
            const assignments = this.extractAssignmentsAtLine(document, lineIdx, classified);
            for (const assign of assignments) {
                const inferredType = this.inferExpressionType(assign.rawExpr, result, nativeCommands, activeIndexer, filePath);
                const existing = result.get(assign.varName.toLowerCase());
                if (inferredType !== 'Any' || !existing) {
                    result.set(assign.varName.toLowerCase(), {
                        name: assign.varName,
                        type: inferredType,
                        line: lineIdx,
                        declarationText: assign.declarationText || document.lineAt(lineIdx).text.trim(),
                        isParameter: existing?.isParameter,
                        depth: currentDepth
                    });
                }
            }
        }

        return result;
    }

    /**
     * Splits comma-separated items outside nested brackets/parentheses
     */
    public static splitTopLevel(str: string): string[] {
        const items: string[] = [];
        let current = '';
        let depth = 0;
        let inString = false;
        let quoteChar = '';

        for (let i = 0; i < str.length; i++) {
            const ch = str[i];
            if (inString) {
                current += ch;
                if (ch === quoteChar) {
                    inString = false;
                }
                continue;
            }

            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                current += ch;
                continue;
            }

            if (ch === '[' || ch === '(' || ch === '{') depth++;
            else if (ch === ']' || ch === ')' || ch === '}') depth--;

            if (ch === ',' && depth === 0) {
                if (current.trim()) items.push(current.trim());
                current = '';
            } else {
                current += ch;
            }
        }
        if (current.trim()) items.push(current.trim());
        return items;
    }

    /**
     * Extracts the balanced content inside brackets following a keyword at top-level depth: keyword [ ... ]
     */
    public static extractBracketArgs(str: string, keyword: string): string | undefined {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        const kwLen = keyword.length;
        const kwLower = keyword.toLowerCase();

        for (let i = 0; i <= str.length - kwLen; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + kwLen).toLowerCase() === kwLower) {
                    const prevChar = i > 0 ? str[i - 1] : ' ';
                    if (/[\s\)\}\],]/.test(prevChar)) {
                        const afterKw = str.slice(i + kwLen).trim();
                        if (afterKw.startsWith('[')) {
                            const startBracket = str.indexOf('[', i + kwLen);
                            let bDepth = 0;
                            let bInString = false;
                            let bQuoteChar = '';
                            for (let j = startBracket; j < str.length; j++) {
                                const bCh = str[j];
                                if (bInString) {
                                    if (bCh === bQuoteChar) bInString = false;
                                    continue;
                                }
                                if (bCh === '"' || bCh === "'") {
                                    bInString = true;
                                    bQuoteChar = bCh;
                                    continue;
                                }
                                if (bCh === '[' || bCh === '(' || bCh === '{') bDepth++;
                                else if (bCh === ']' || bCh === ')' || bCh === '}') {
                                    bDepth--;
                                    if (bDepth === 0) {
                                        return str.slice(startBracket + 1, j);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return undefined;
    }

    /**
     * Checks if a string is fully enclosed by parentheses, e.g. (a >> b)
     */
    public static isFullyEnclosed(str: string): boolean {
        const trimmed = str.trim();
        if (!trimmed.startsWith('(') || !trimmed.endsWith(')')) return false;
        let depth = 0;
        let inString = false;
        let quoteChar = '';
        for (let i = 0; i < trimmed.length - 1; i++) {
            const ch = trimmed[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '(') depth++;
            else if (ch === ')') depth--;
            if (depth === 0) return false;
        }
        return depth === 1;
    }

    /**
     * Checks if an operator exists at top-level depth (outside quotes and brackets/parentheses)
     */
    public static hasTopLevelOperator(str: string, op: string): boolean {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        for (let i = 0; i <= str.length - op.length; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + op.length) === op) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Checks if a word command exists at top-level depth between two operands (outside quotes and brackets/parentheses).
     * E.g. `<left> isKindOf <right>` or `<left> in <right>`
     */
    public static hasTopLevelWordCommand(str: string, command: string): boolean {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        const cmdLen = command.length;
        const cmdLower = command.toLowerCase();

        for (let i = 0; i <= str.length - cmdLen; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + cmdLen).toLowerCase() === cmdLower) {
                    const prevChar = i > 0 ? str[i - 1] : ' ';
                    const nextChar = i + cmdLen < str.length ? str[i + cmdLen] : ' ';
                    if (/[\s\)]/.test(prevChar) && /[\s\(]/.test(nextChar)) {
                        const before = str.slice(0, i).trim();
                        const after = str.slice(i + cmdLen).trim();
                        if (before.length > 0 && after.length > 0) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    /**
     * Finds the index of a top-level keyword outside brackets, parentheses, braces, and quotes.
     */
    public static findTopLevelWord(str: string, word: string): number {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        const wordLen = word.length;
        const wordLower = word.toLowerCase();

        for (let i = 0; i <= str.length - wordLen; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + wordLen).toLowerCase() === wordLower) {
                    const prevChar = i > 0 ? str[i - 1] : ' ';
                    const nextChar = i + wordLen < str.length ? str[i + wordLen] : ' ';
                    if (/[\s\)\}\],]/.test(prevChar) && /[\s\(\{\[,;]/.test(nextChar)) {
                        return i;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Finds the index of a top-level operator outside brackets, parentheses, braces, and quotes.
     */
    public static findTopLevelOperatorIndex(str: string, op: string): number {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        for (let i = 0; i <= str.length - op.length; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + op.length) === op) {
                    return i;
                }
            }
        }
        return -1;
    }

    /**
     * Splits statements separated by top-level semicolons outside quotes and nested brackets/braces/parentheses.
     */
    public static splitTopLevelSemicolons(str: string): string[] {
        const items: string[] = [];
        let current = '';
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        for (let i = 0; i < str.length; i++) {
            const ch = str[i];
            if (inString) {
                current += ch;
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                current += ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (ch === ';' && depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (current.trim()) items.push(current.trim());
                current = '';
            } else {
                current += ch;
            }
        }
        if (current.trim()) items.push(current.trim());
        return items;
    }

    /**
     * Checks if a statement or block is syntactically balanced and terminated by a top-level semicolon.
     */
    public static isStatementComplete(text: string): boolean {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';
        let hasTopLevelSemicolon = false;

        for (let i = 0; i < text.length; i++) {
            const ch = text[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (ch === ';' && depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                hasTopLevelSemicolon = true;
            }
        }

        return depthBracket <= 0 && depthParen <= 0 && depthBrace <= 0 && hasTopLevelSemicolon;
    }

    /**
     * Extracts variable assignments from a code line or multiline block: [private] _var = <expression>;
     */
    public static extractAssignments(text: string): Array<{ varName: string, rawExpr: string }> {
        const results: Array<{ varName: string, rawExpr: string }> = [];
        const assignRegex = /(?:(?:private\s+)?(_[a-zA-Z0-9_]+)\s*=\s*)/g;
        let m: RegExpExecArray | null;
        while ((m = assignRegex.exec(text)) !== null) {
            const varName = m[1];
            const startIdx = m.index + m[0].length;
            let depthBracket = 0;
            let depthParen = 0;
            let depthBrace = 0;
            let inString = false;
            let quoteChar = '';
            let endIdx = text.length;

            for (let i = startIdx; i < text.length; i++) {
                const ch = text[i];
                if (inString) {
                    if (ch === quoteChar) inString = false;
                    continue;
                }
                if (ch === '"' || ch === "'") {
                    inString = true;
                    quoteChar = ch;
                    continue;
                }
                if (ch === '[') depthBracket++;
                else if (ch === ']') depthBracket--;
                else if (ch === '(') depthParen++;
                else if (ch === ')') depthParen--;
                else if (ch === '{') depthBrace++;
                else if (ch === '}') depthBrace--;

                if (ch === ';' && depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                    endIdx = i;
                    break;
                }
            }
            let expr = text.slice(startIdx, endIdx).trim();
            expr = expr.replace(/;+\s*$/, '').trim();
            if (expr) {
                results.push({
                    varName,
                    rawExpr: expr
                });
            }
            assignRegex.lastIndex = Math.max(assignRegex.lastIndex, endIdx);
        }
        return results;
    }

    /**
     * Extracts assignments starting at lineIdx, accumulating subsequent lines if the statement is multiline.
     */
    public static extractAssignmentsAtLine(
        document: vscode.TextDocument,
        lineIdx: number,
        classified: ClassifiedDocument
    ): Array<{ varName: string, rawExpr: string, declarationText: string }> {
        const cleanLine = classified.getLineMaskedCommentsOnly(lineIdx);
        const trimmed = cleanLine.trim();
        if (!trimmed || trimmed.startsWith('#')) {
            return [];
        }

        if (!/(?:private\s+)?_[a-zA-Z0-9_]+\s*=/i.test(trimmed)) {
            return [];
        }

        let statementText = trimmed;
        let lookAhead = lineIdx;
        const maxLines = Math.min(document.lineCount - 1, lineIdx + 60);

        while (!this.isStatementComplete(statementText) && lookAhead < maxLines) {
            lookAhead++;
            const nextLine = classified.getLineMaskedCommentsOnly(lookAhead).trim();
            if (nextLine.startsWith('#')) continue;
            statementText += '\n' + nextLine;
        }

        const assigns = this.extractAssignments(statementText);
        return assigns.map(a => ({
            ...a,
            declarationText: document.lineAt(lineIdx).text.trim()
        }));
    }

    /**
     * Checks if a type represents an Arma position or vector representation.
     */
    public static isPositionType(t: string): boolean {
        if (!t) return false;
        const lower = t.toLowerCase();
        return lower === 'vector3d' || lower.includes('position') || lower.startsWith('position3d');
    }

    /**
     * Resolves the type of a preprocessor #define constant from script_component.hpp or component headers
     */
    public static resolveDefine(name: string, filePath?: string): string | undefined {
        if (!filePath) return undefined;
        try {
            let dir = path.dirname(filePath);
            for (let i = 0; i < 4; i++) {
                const sc = path.join(dir, 'script_component.hpp');
                if (fs.existsSync(sc)) {
                    const content = fs.readFileSync(sc, 'utf8');
                    const reg = new RegExp(`^\\s*#\\s*define\\s+${name}\\b\\s+(.+)$`, 'm');
                    const m = content.match(reg);
                    if (m) {
                        const val = m[1].trim();
                        if (/^-?\d+(\.\d+)?$/.test(val)) return 'Number';
                        if (/^"[^"]*"$/.test(val) || /^'[^']*'$/.test(val)) return 'String';
                        if (val.toLowerCase() === 'true' || val.toLowerCase() === 'false') return 'Boolean';
                        return undefined;
                    }
                }
                const parent = path.dirname(dir);
                if (parent === dir) break;
                dir = parent;
            }
        } catch {
            // Ignore file read errors
        }
        return undefined;
    }

    /**
     * Detects type narrowing guards in conditional expressions like 'if (_var isEqualType sample)'
     */
    public static detectTypeNarrowing(conditionStr: string): Array<{ varName: string; narrowedType: string }> {
        const results: Array<{ varName: string; narrowedType: string }> = [];
        const reEqual = /\b(_[a-zA-Z0-9_]+)\s+isEqualType\s+([a-zA-Z0-9_]+|\[\]|""|''|\{\})/gi;
        let match: RegExpExecArray | null;
        while ((match = reEqual.exec(conditionStr)) !== null) {
            const varName = match[1];
            const sample = match[2];
            const narrowed = this.inferTypeFromSample(sample);
            if (narrowed && narrowed !== 'Any') {
                results.push({ varName, narrowedType: narrowed });
            }
        }
        return results;
    }

    /**
     * Parse all params [...] blocks across the document
     */
    public static parseAllParams(
        text: string,
        varMap: Map<string, InferredVariable>,
        classified?: ClassifiedDocument,
        options?: { maxLine?: number; topLevelOnly?: boolean }
    ) {
        const paramsRegex = /\bparams\s*\[([\s\S]*?)\]\s*;/gi;
        let pMatch: RegExpExecArray | null;

        while ((pMatch = paramsRegex.exec(text)) !== null) {
            // Skip params statements inside strings
            if (classified && classified.isInsideString(pMatch.index)) {
                continue;
            }

            const matchLine = classified ? classified.getLineFromOffset(pMatch.index) : 0;
            if (options?.maxLine !== undefined && matchLine > options.maxLine) {
                continue;
            }

            const depth = classified ? classified.getBraceDepth(pMatch.index) : 0;
            if (options?.topLevelOnly && depth > 0) {
                continue;
            }

            const innerParams = pMatch[1];
            const elements = this.splitTopLevel(innerParams);

            for (const el of elements) {
                if (el.startsWith('[') && el.endsWith(']')) {
                    const parts = this.splitTopLevel(el.slice(1, -1));
                    const nameMatch = parts[0]?.match(/"(_[a-zA-Z0-9_]+)"/);
                    if (!nameMatch) continue;

                    const varName = nameMatch[1];
                    const defaultVal = parts[1]?.trim() || '';
                    const typesArr = parts[2]?.trim() || '';

                    const inferredType = this.inferParamType(defaultVal, typesArr);
                    const existing = varMap.get(varName.toLowerCase());

                    // If existing is a top-level parameter (depth === 0) and current is inside an inner closure (depth > 0),
                    // do not overwrite the top-level parameter.
                    if (existing && existing.isParameter && (existing.depth ?? 0) === 0 && depth > 0) {
                        continue;
                    }

                    varMap.set(varName.toLowerCase(), {
                        name: varName,
                        type: inferredType,
                        line: matchLine,
                        declarationText: el,
                        isParameter: true,
                        depth
                    });
                } else {
                    const nameMatch = el.match(/"(_[a-zA-Z0-9_]+)"/);
                    if (nameMatch) {
                        const existing = varMap.get(nameMatch[1].toLowerCase());
                        if (existing && existing.isParameter && (existing.depth ?? 0) === 0 && depth > 0) {
                            continue;
                        }
                        varMap.set(nameMatch[1].toLowerCase(), {
                            name: nameMatch[1],
                            type: 'Any',
                            line: matchLine,
                            declarationText: el,
                            isParameter: true,
                            depth
                        });
                    }
                }
            }
        }
    }

    /**
     * Infer type for a params element: [varName, defaultVal, typesArr]
     * In SQF engine documentation for 'params':
     * - An empty types array [] as 3rd arg means NO type validation (ANY type is accepted).
     * - To require an Array, the 3rd arg must have an array sample inside, e.g. [[]] or [[], ""].
     * - If 3rd arg is omitted, type is inferred from defaultVal if available.
     */
    public static inferParamType(defaultVal: string, typesArr: string): string {
        const trimmedTypes = typesArr ? typesArr.trim() : '';

        if (trimmedTypes) {
            if (trimmedTypes.startsWith('[') && trimmedTypes.endsWith(']')) {
                const inner = trimmedTypes.slice(1, -1).trim();
                if (!inner) {
                    // Empty filter array [] means ANY type accepted!
                    return 'Any';
                }
                const samples = this.splitTopLevel(inner);
                const types = new Set<string>();
                for (const sample of samples) {
                    const t = this.inferTypeFromSample(sample);
                    if (t && t !== 'Any') {
                        types.add(t);
                    }
                }
                return types.size > 0 ? Array.from(types).join(' | ') : 'Any';
            } else {
                return this.inferTypeFromSample(trimmedTypes);
            }
        }

        if (defaultVal) {
            return this.inferTypeFromSample(defaultVal);
        }

        return 'Any';
    }

    /**
     * Infer a single type from a sample expression (e.g. [], "", 0, controlNull, createHashMap)
     */
    public static inferTypeFromSample(sample: string): string {
        const s = sample.trim();
        if (!s) return 'Any';
        const lower = s.toLowerCase();

        if (s.startsWith('[') && s.endsWith(']')) return 'Array';
        if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) return 'String';
        if (/^-?\d+(?:\.\d+)?$/.test(s)) return 'Number';
        if (lower === 'true' || lower === 'false') return 'Boolean';
        if (s.startsWith('{') && s.endsWith('}')) return 'Code';

        if (lower.includes('controlnull')) return 'Control';
        if (lower.includes('displaynull')) return 'Display';
        if (lower.includes('objnull') || lower === 'player' || lower === 'cursorobject' || lower === 'cursortarget' || lower === 'cameraon') return 'Object';
        if (lower.includes('grpnull')) return 'Group';
        if (lower.includes('locationnull')) return 'Location';
        if (lower.includes('tasknull')) return 'Task';
        if (lower.includes('confignull') || lower.includes('configfile') || lower.includes('missionconfigfile') || lower.includes('campaignconfigfile') || sample.includes('>>')) return 'Config';
        if (lower.includes('createhashmap')) return 'HashMap';

        return 'Any';
    }

    /**
     * Determine all allowed types from a params type-filter array
     */
    public static inferTypesFromFilter(filterStr: string): string {
        return this.inferParamType('', filterStr);
    }

    /**
     * Finds the index of the top-level 'call' keyword (outside quotes, brackets, parens, braces)
     */
    public static findTopLevelCall(str: string): number {
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';
        let lastCallIdx = -1;

        for (let i = 0; i < str.length; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket--;
            else if (ch === '(') depthParen++;
            else if (ch === ')') depthParen--;
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace--;

            if (depthBracket === 0 && depthParen === 0 && depthBrace === 0) {
                if (str.substring(i, i + 4).toLowerCase() === 'call') {
                    const prevChar = i > 0 ? str[i - 1] : ' ';
                    const nextChar = i + 4 < str.length ? str[i + 4] : ' ';
                    if (/[\s\],)]/.test(prevChar) && /[\s\(\[{]/.test(nextChar)) {
                        lastCallIdx = i;
                    }
                }
            }
        }
        return lastCallIdx;
    }

    /**
     * Parse the return type from a function's Returns: docblock description string.
     */
    public static parseReturnType(returnStr: string): string {
        if (!returnStr) return 'Any';
        const lines = returnStr.trim().split('\n');
        const firstLine = lines[0].replace(/^[-*]\s*/, '').trim();
        if (!firstLine) return 'Any';

        // Check if array bracket format: [STRING, NUMBER]
        if (firstLine.startsWith('[')) return 'Array';

        // Handle union types: e.g. "ARRAY or BOOLEAN" or "ARRAY | STRING"
        const unionParts = firstLine.split(/\s+(?:or|\|)\s+/i);
        if (unionParts.length > 1) {
            const types = unionParts
                .map(p => this.parseReturnType(p))
                .filter(t => t && t !== 'Any');
            if (types.length > 0) {
                return Array.from(new Set(types)).join(' | ');
            }
        }

        const lower = firstLine.toLowerCase();

        const arrayMatch = firstLine.match(/^\s*array(?:\s+of\s+([a-zA-Z0-9_]+)|<([a-zA-Z0-9_]+)>)/i);
        if (arrayMatch) {
            const innerRaw = arrayMatch[1] || arrayMatch[2];
            const innerType = this.parseReturnType(innerRaw);
            if (innerType && innerType !== 'Any') {
                return `Array<${innerType}>`;
            }
            return 'Array';
        }

        if (/^\s*waypoint\b/i.test(lower)) return 'Waypoint';
        if (/^\s*array\b/i.test(lower)) return 'Array';
        if (/^\s*hashmap\b/i.test(lower) || /^\s*hash_map\b/i.test(lower)) return 'HashMap';
        if (/^\s*string\b/i.test(lower)) return 'String';
        if (/^\s*(?:number|scalar)\b/i.test(lower)) return 'Number';
        if (/^\s*(?:boolean|bool)\b/i.test(lower)) return 'Boolean';
        if (/^\s*config\b/i.test(lower)) return 'Config';
        if (/^\s*control\b/i.test(lower)) return 'Control';
        if (/^\s*display\b/i.test(lower)) return 'Display';
        if (/^\s*object\b/i.test(lower)) return 'Object';
        if (/^\s*group\b/i.test(lower)) return 'Group';
        if (/^\s*code\b/i.test(lower)) return 'Code';
        if (/^\s*location\b/i.test(lower)) return 'Location';
        if (/^\s*task\b/i.test(lower)) return 'Task';
        if (/^\s*(?:nothing|none|void)\b/i.test(lower)) return 'Nothing';

        return 'Any';
    }

    /**
     * Infers the return type of a call expression target.
     */
    public static inferCallReturnType(
        target: string,
        indexer?: WorkspaceIndexer,
        filePath?: string,
        knownVars?: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager
    ): string {
        let cleanTarget = target.trim();
        if (this.isFullyEnclosed(cleanTarget)) {
            cleanTarget = cleanTarget.slice(1, -1).trim();
        }
        if (!cleanTarget) return 'Any';

        // Code block literal: { ... }
        if (cleanTarget.startsWith('{') && cleanTarget.endsWith('}')) {
            const inner = cleanTarget.slice(1, -1).trim();
            return this.inferExpressionType(inner, knownVars || new Map(), nativeCommands, indexer, filePath);
        }

        // Variable reference: _myCode
        if (cleanTarget.startsWith('_') && knownVars && knownVars.has(cleanTarget.toLowerCase())) {
            const v = knownVars.get(cleanTarget.toLowerCase())!;
            if (v.type && v.type !== 'Any' && v.type !== 'Code') {
                return v.type;
            }
        }

        // Built-in / common BIS or CBA functions
        const lowerTarget = cleanTarget.toLowerCase();
        if (this.KNOWN_FUNCTION_RETURNS[lowerTarget]) {
            return this.KNOWN_FUNCTION_RETURNS[lowerTarget];
        }

        const activeIndexer = indexer || this.defaultIndexer;
        let fnInfo: CustomFunctionInfo | undefined;
        let compToSearch: string | undefined;
        let fncToSearch: string | undefined;

        // Check if CBA macro: EFUNC(comp, fnc) or QEFUNC(comp, fnc)
        const efuncMatch = cleanTarget.match(/\bQ?EFUNC\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/i);
        if (efuncMatch) {
            compToSearch = efuncMatch[1];
            fncToSearch = efuncMatch[2];
        }

        // Check if CBA macro: FUNC(fnc) or QFUNC(fnc)
        if (!compToSearch) {
            const funcMatch = cleanTarget.match(/\bQ?FUNC\s*\(\s*([_a-zA-Z0-9]+)\s*\)/i);
            if (funcMatch) {
                fncToSearch = funcMatch[1];
                if (filePath) {
                    try {
                        const ctx = CbaResolver.resolveContext(filePath);
                        compToSearch = ctx.component;
                    } catch {
                        // Ignore
                    }
                }
            }
        }

        // Resolve via indexer
        if (activeIndexer) {
            if (compToSearch && fncToSearch) {
                fnInfo = activeIndexer.findFunction(compToSearch, fncToSearch);
            }

            if (!fnInfo && fncToSearch) {
                fnInfo = activeIndexer.findFunction(undefined, fncToSearch);
            }

            if (!fnInfo) {
                fnInfo = activeIndexer.findFunction(undefined, undefined, cleanTarget) ||
                         activeIndexer.getFunction(cleanTarget);
            }

            if (!fnInfo && cleanTarget.includes('_fnc_')) {
                const parts = cleanTarget.split('_fnc_');
                fnInfo = activeIndexer.findFunction(undefined, parts[1]);
            }

            if (fnInfo && fnInfo.returns) {
                const parsed = this.parseReturnType(fnInfo.returns);
                if (parsed && parsed !== 'Any') {
                    return parsed;
                }
            }
        }

        // Fallback: If not found in indexer but file exists on disk, read directly
        if (!fnInfo && filePath && compToSearch && fncToSearch) {
            try {
                let current = path.dirname(filePath);
                const root = path.parse(filePath).root;
                let addonsDir = '';
                while (current !== root) {
                    const candidate = path.join(current, 'addons');
                    if (fs.existsSync(candidate)) {
                        addonsDir = candidate;
                        break;
                    }
                    if (path.basename(current).toLowerCase() === 'addons') {
                        addonsDir = current;
                        break;
                    }
                    current = path.dirname(current);
                }

                if (addonsDir) {
                    const candidateFiles = [
                        path.join(addonsDir, compToSearch, 'functions', `fnc_${fncToSearch}.sqf`),
                        path.join(addonsDir, compToSearch, 'functions', 'list', `fnc_${fncToSearch}.sqf`)
                    ];
                    for (const candidateFile of candidateFiles) {
                        if (fs.existsSync(candidateFile)) {
                            const content = fs.readFileSync(candidateFile, 'utf-8');
                            const doc = SqfDocParser.parseFile(content);
                            if (doc.returns) {
                                const parsed = this.parseReturnType(doc.returns);
                                if (parsed && parsed !== 'Any') {
                                    return parsed;
                                }
                            }
                            break;
                        }
                    }
                }
            } catch {
                // Ignore fallback errors
            }
        }

        return 'Any';
    }

    /**
     * Infers the element type of an array expression (from Array<T>, array literal, or known command returns).
     */
    public static inferArrayElementType(
        expr: string,
        knownVars: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager,
        indexer?: WorkspaceIndexer,
        filePath?: string
    ): string {
        let clean = expr.trim();
        if (this.isFullyEnclosed(clean)) {
            clean = clean.slice(1, -1).trim();
        }
        if (!clean) return 'Any';

        // 1. Array literal: [elem0, elem1, ...]
        if (clean.startsWith('[') && clean.endsWith(']')) {
            const elements = this.splitTopLevel(clean.slice(1, -1));
            if (elements.length > 0) {
                const types = new Set<string>();
                for (const el of elements) {
                    const t = this.inferExpressionType(el.trim(), knownVars, nativeCommands, indexer, filePath);
                    if (t && t !== 'Any') {
                        types.add(t);
                    }
                }
                if (types.size > 0) {
                    return Array.from(types).join(' | ');
                }
            }
            return 'Any';
        }

        // 2. Local variable: _nearEntities
        if (clean.startsWith('_')) {
            const varInfo = knownVars.get(clean.toLowerCase());
            if (varInfo) {
                const t = varInfo.type;
                const m = t.match(/^Array<(.+)>$/i) || t.match(/^Array\s+of\s+(.+)$/i);
                if (m) {
                    return m[1];
                }
                const source = (varInfo.declarationText || '').toLowerCase();
                for (const [cmd, elem] of Object.entries(this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES)) {
                    if (new RegExp(`\\b${cmd}\\b`, 'i').test(source)) {
                        return elem;
                    }
                }
            }
        }

        // 3. Directly infer expression type:
        const exprType = this.inferExpressionType(clean, knownVars, nativeCommands, indexer, filePath);
        const m = exprType.match(/^Array<(.+)>$/i) || exprType.match(/^Array\s+of\s+(.+)$/i);
        if (m) {
            return m[1];
        }

        // 4. Check if expr itself contains a known command:
        const cleanLower = clean.toLowerCase();
        for (const [cmd, elem] of Object.entries(this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES)) {
            if (new RegExp(`\\b${cmd}\\b`, 'i').test(cleanLower)) {
                return elem;
            }
        }

        return 'Any';
    }

    /**
     * Finds a top-level binary command in an expression outside brackets/parentheses/braces/strings.
     * E.g. in "(group _veh) addWaypoint [...]", finds "addWaypoint".
     */
    public static findTopLevelBinaryCommand(
        str: string,
        nativeCommands?: NativeCommandsManager
    ): { name: string; left: string; right: string } | undefined {
        if (!nativeCommands) return undefined;
        let depthBracket = 0;
        let depthParen = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';
        let lastCandidate: { name: string; left: string; right: string } | undefined;

        for (let i = 0; i < str.length; i++) {
            const ch = str[i];
            if (inString) {
                if (ch === quoteChar) inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '(') { depthParen++; continue; }
            if (ch === ')') { depthParen = Math.max(0, depthParen - 1); continue; }
            if (ch === '[') { depthBracket++; continue; }
            if (ch === ']') { depthBracket = Math.max(0, depthBracket - 1); continue; }
            if (ch === '{') { depthBrace++; continue; }
            if (ch === '}') { depthBrace = Math.max(0, depthBrace - 1); continue; }

            if (depthParen === 0 && depthBracket === 0 && depthBrace === 0) {
                if (/[a-zA-Z0-9_]/.test(ch)) {
                    if (i > 0 && /[a-zA-Z0-9_]/.test(str[i - 1])) continue;
                    let wordEnd = i;
                    while (wordEnd < str.length && /[a-zA-Z0-9_]/.test(str[wordEnd])) wordEnd++;
                    const word = str.slice(i, wordEnd);
                    const wordLower = word.toLowerCase();

                    const before = str.slice(0, i).trim();
                    const after = str.slice(wordEnd).trim();

                    if (before && after) {
                        const lastBeforeChar = before[before.length - 1];
                        if (![';', '{', '(', '[', ',', '=', '+', '-', '*', '/', '!', '>', '<'].includes(lastBeforeChar)) {
                            if (!this.KEYWORDS.has(wordLower) && wordLower !== 'select' && wordLower !== 'apply' && wordLower !== 'call') {
                                const hasKnownArrayElem = !!this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES[wordLower];
                                const cmd = nativeCommands.getCommand(word);
                                const hasBinarySyntax = cmd && cmd.syntaxes && cmd.syntaxes.some(s => s.callType === 'binary');

                                if (hasKnownArrayElem || hasBinarySyntax) {
                                    lastCandidate = { name: word, left: before, right: after };
                                }
                            }
                        }
                    }
                    i = wordEnd - 1;
                }
            }
        }
        return lastCandidate;
    }

    /**
     * Infer type of a raw expression
     */
    public static inferExpressionType(
        expr: string,
        knownVars: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager,
        indexer?: WorkspaceIndexer,
        filePath?: string
    ): string {
        let trimmed = expr.trim();
        if (!trimmed) return 'Any';

        const activeIndexer = indexer || this.defaultIndexer;

        // Unwrap fully enclosed outer parentheses: (a >> b) -> a >> b
        if (this.isFullyEnclosed(trimmed)) {
            trimmed = trimmed.slice(1, -1).trim();
        }

        // Check for if-then-else expression: if (cond) then { branch1 } else { branch2 }
        if (/^if\b/i.test(trimmed)) {
            const thenIdx = this.findTopLevelWord(trimmed, 'then');
            if (thenIdx !== -1) {
                const afterThen = trimmed.slice(thenIdx + 4).trim();
                const elseIdx = this.findTopLevelWord(afterThen, 'else');
                const thenPart = elseIdx !== -1 ? afterThen.slice(0, elseIdx).trim() : afterThen;
                const elsePart = elseIdx !== -1 ? afterThen.slice(elseIdx + 4).trim() : undefined;

                const evalBlock = (block: string | undefined): string => {
                    if (!block) return 'Any';
                    let inner = block.trim();
                    if (this.isFullyEnclosed(inner)) {
                        inner = inner.slice(1, -1).trim();
                    }
                    if (inner.startsWith('{') && inner.endsWith('}')) {
                        inner = inner.slice(1, -1).trim();
                    }
                    const stmts = this.splitTopLevelSemicolons(inner);
                    const lastStmt = stmts.length > 0 ? stmts[stmts.length - 1].trim() : inner;
                    if (!lastStmt) return 'Any';
                    return this.inferExpressionType(lastStmt, knownVars, nativeCommands, activeIndexer, filePath);
                };

                const thenType = evalBlock(thenPart);
                const elseType = elsePart ? evalBlock(elsePart) : 'Any';

                if (thenType !== 'Any' && elseType !== 'Any') {
                    if (thenType === elseType) return thenType;
                    return `${thenType} | ${elseType}`;
                }
                if (thenType !== 'Any') return thenType;
                if (elseType !== 'Any') return elseType;
                return 'Any';
            }
        }

        // 1. Check for getOrDefault: hashmap getOrDefault [key, defaultValue, createIfMissing]
        const getOrDefaultArgs = this.extractBracketArgs(trimmed, 'getOrDefault');
        if (getOrDefaultArgs !== undefined) {
            const args = this.splitTopLevel(getOrDefaultArgs);
            if (args.length >= 2) {
                return this.inferExpressionType(args[1].trim(), knownVars, nativeCommands, activeIndexer, filePath);
            }
        }

        // 2. Check for getVariable with default value: target getVariable [name, defaultVal]
        const getVarArgs = this.extractBracketArgs(trimmed, 'getVariable');
        if (getVarArgs !== undefined) {
            const args = this.splitTopLevel(getVarArgs);
            if (args.length >= 2) {
                return this.inferExpressionType(args[1].trim(), knownVars, nativeCommands, activeIndexer, filePath);
            }
        }

        // 3. Config traversal operator: config >> string / entry
        // In SQF, >> is strictly the config path operator, always returning Config
        if (this.hasTopLevelOperator(trimmed, '>>')) {
            return 'Config';
        }

        // Boolean negation: !expr
        if (trimmed.startsWith('!')) {
            return 'Boolean';
        }

        // Boolean binary comparison and check operators (e.g. left isKindOf right)
        if (this.hasTopLevelWordCommand(trimmed, 'isKindOf') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualTo') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualType') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualTypeAll') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualTypeAny') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualTypeArray') ||
            this.hasTopLevelWordCommand(trimmed, 'isEqualTypeParams') ||
            this.hasTopLevelWordCommand(trimmed, 'in') ||
            this.hasTopLevelOperator(trimmed, '==') ||
            this.hasTopLevelOperator(trimmed, '!=') ||
            this.hasTopLevelOperator(trimmed, '&&') ||
            this.hasTopLevelOperator(trimmed, '||') ||
            this.hasTopLevelOperator(trimmed, '<=') ||
            this.hasTopLevelOperator(trimmed, '>=') ||
            this.hasTopLevelOperator(trimmed, '<') ||
            this.hasTopLevelOperator(trimmed, '>')) {
            return 'Boolean';
        }

        // random command returns Number
        if (/^random\b/i.test(trimmed)) {
            return 'Number';
        }

        // Check for top-level select: <left> select <right>
        const selectIdx = this.findTopLevelWord(trimmed, 'select');
        if (selectIdx !== -1) {
            const leftExpr = trimmed.slice(0, selectIdx).trim();
            const rightExpr = trimmed.slice(selectIdx + 6).trim();

            if (leftExpr && rightExpr) {
                // 1. Array boolean select: [falseVal, trueVal] select bool
                if (leftExpr.startsWith('[') && leftExpr.endsWith(']')) {
                    const elements = this.splitTopLevel(leftExpr.slice(1, -1));
                    if (elements.length >= 2) {
                        const rightType = this.inferExpressionType(rightExpr, knownVars, nativeCommands, activeIndexer, filePath);
                        if (rightType === 'Boolean' || rightType === 'Any') {
                            const type0 = this.inferExpressionType(elements[0].trim(), knownVars, nativeCommands, activeIndexer, filePath);
                            const type1 = this.inferExpressionType(elements[1].trim(), knownVars, nativeCommands, activeIndexer, filePath);
                            if (type0 !== 'Any' && type1 !== 'Any') {
                                return type0 === type1 ? type0 : `${type0} | ${type1}`;
                            }
                            if (type0 !== 'Any') return type0;
                            if (type1 !== 'Any') return type1;
                        }
                    }
                }

                // 2. Filter array by code block condition: <array> select { ... } -> Array
                if (rightExpr.startsWith('{')) {
                    return 'Array';
                }

                // 3. Subarray selection: <array> select [start, count] -> Array
                if (rightExpr.startsWith('[') && rightExpr.includes(',')) {
                    const leftType = this.inferExpressionType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);
                    if (leftType === 'String') return 'String';
                    return 'Array';
                }

                // 4. Config selection: <config> select <index> -> Config
                const leftType = this.inferExpressionType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);
                if (leftType === 'Config') {
                    return 'Config';
                }

                // 5. Index into Array<T> or Waypoint: <array> select <number> -> T
                const rightType = this.inferExpressionType(rightExpr, knownVars, nativeCommands, activeIndexer, filePath);
                if (rightType === 'Number' || rightType === 'Any') {
                    const leftType = this.inferExpressionType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);
                    if (leftType.toLowerCase() === 'waypoint') {
                        const idx = parseInt(rightExpr, 10);
                        if (idx === 0) return 'Group';
                        if (idx === 1) return 'Number';
                    }
                    const elem = this.inferArrayElementType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);
                    if (elem && elem !== 'Any') {
                        return elem;
                    }
                }

                return 'Any';
            }
        }

        // Check for top-level apply: <left> apply <right> -> Array
        const applyIdx = this.findTopLevelWord(trimmed, 'apply');
        if (applyIdx !== -1) {
            const leftExpr = trimmed.slice(0, applyIdx).trim();
            const rightExpr = trimmed.slice(applyIdx + 5).trim();
            if (leftExpr && rightExpr) {
                return 'Array';
            }
        }

        // Literal array: starts with '[' and ends with ']'
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            return 'Array';
        }

        // Check for array index select operator: <array> # <index>
        const hashIdx = this.findTopLevelOperatorIndex(trimmed, '#');
        if (hashIdx > 0) {
            const leftExpr = trimmed.slice(0, hashIdx).trim();
            const rightExpr = trimmed.slice(hashIdx + 1).trim();

            const leftType = this.inferExpressionType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);

            if (this.isPositionType(leftType)) {
                return 'Number';
            }

            if (leftType.toLowerCase() === 'waypoint') {
                const idx = parseInt(rightExpr, 10);
                if (idx === 0) return 'Group';
                if (idx === 1) return 'Number';
            }

            const elem = this.inferArrayElementType(leftExpr, knownVars, nativeCommands, activeIndexer, filePath);
            if (elem && elem !== 'Any') {
                return elem;
            }

            if (leftExpr.startsWith('[') && leftExpr.endsWith(']')) {
                const elements = this.splitTopLevel(leftExpr.slice(1, -1));
                const idx = parseInt(rightExpr, 10);
                if (!isNaN(idx) && elements[idx] !== undefined) {
                    return this.inferExpressionType(elements[idx].trim(), knownVars, nativeCommands, activeIndexer, filePath);
                }
            }

            const leftLower = leftExpr.toLowerCase();
            const varInfo = knownVars.get(leftLower);
            const sourceCode = (varInfo?.declarationText || leftExpr).toLowerCase();
            if (/\b(?:synchronizedobjects|allunits|allplayers|allcurators|allvehicles|units|vehicles|playableunits|switchableunits)\b/i.test(sourceCode)) {
                return 'Object';
            }
            if (/\b(?:allgroups|groups)\b/i.test(sourceCode)) {
                return 'Group';
            }
            if (/\b(?:allmines)\b/i.test(sourceCode)) {
                return 'Object';
            }
            if (/\b(?:allmapmarkers)\b/i.test(sourceCode)) {
                return 'String';
            }

            return 'Any';
        }

        // Copy array / prefix + operator: +_arr or +[...]
        if (trimmed.startsWith('+')) {
            const rest = trimmed.slice(1).trim();
            return this.inferExpressionType(rest, knownVars, nativeCommands, activeIndexer, filePath);
        }

        // Literal string: "..." or '...'
        if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
            (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
            return 'String';
        }

        // Literal boolean: true or false
        if (trimmed === 'true' || trimmed === 'false') {
            return 'Boolean';
        }

        // Literal number: digits, float, hex, scientific notation
        if (/^-?(?:0x[0-9a-fA-F]+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)$/.test(trimmed)) {
            return 'Number';
        }

        // Literal code block: { ... } or starts with '{' (multiline code block)
        if (trimmed.startsWith('{')) {
            return 'Code';
        }

        // Known null / global singletons
        const lower = trimmed.toLowerCase();
        if (this.KNOWN_CONSTRUCTORS[lower]) {
            return this.KNOWN_CONSTRUCTORS[lower];
        }

        // All-caps preprocessor constant / define (e.g. PLANE_HEIGHT, IDC_..., etc.)
        if (/^[A-Z][A-Z0-9_]{1,}$/.test(trimmed)) {
            const defType = this.resolveDefine(trimmed, filePath);
            if (defType) return defType;
        }

        // Reference to another known local variable: _otherVar
        if (knownVars.has(lower)) {
            return knownVars.get(lower)!.type;
        }

        // CBA function reference or raw function: FUNC(var), EFUNC(comp, var), or prefix_fnc_xxx
        if (/^Q?E?FUNC\s*\([^)]*\)$/i.test(trimmed)) {
            return 'Code';
        }
        if (/^[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+$/i.test(trimmed)) {
            return 'Code';
        }

        // 4. Check for function calls: ... call <target>
        let callTarget: string | undefined;
        const callIdx = this.findTopLevelCall(trimmed);
        if (callIdx !== -1) {
            callTarget = trimmed.slice(callIdx + 4).trim();
        } else {
            const callMatch = trimmed.match(/\bcall\s+(?:\(([\s\S]+)\)|([_a-zA-Z0-9]+(?:\([^)]*\))?))\s*$/i);
            if (callMatch) {
                callTarget = (callMatch[1] || callMatch[2]).trim();
            }
        }

        if (callTarget) {
            if (this.isFullyEnclosed(callTarget)) {
                callTarget = callTarget.slice(1, -1).trim();
            }
            const inferredCall = this.inferCallReturnType(callTarget, activeIndexer, filePath, knownVars, nativeCommands);
            if (inferredCall && inferredCall !== 'Any') {
                return inferredCall;
            }
        }

        // Native command lookup (binary, unary, or nular)
        if (nativeCommands) {
            // 1. Check if expression contains a top-level binary command: e.g. "(group _veh) addWaypoint [...]" or "_grp addWaypoint [...]"
            const topBinary = this.findTopLevelBinaryCommand(trimmed, nativeCommands);
            if (topBinary) {
                const cmdLower = topBinary.name.toLowerCase();
                const elemType = this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES[cmdLower];
                if (elemType) {
                    return `Array<${elemType}>`;
                }

                const opCmd = nativeCommands.getCommand(topBinary.name);
                if (opCmd && opCmd.syntaxes) {
                    const binSyn = opCmd.syntaxes.find(s => s.callType === 'binary');
                    if (binSyn && binSyn.returnType && binSyn.returnType !== 'Nothing') {
                        return binSyn.returnType;
                    }
                }
            }

            // 2. Check if expression begins with a unary command: e.g. "lbSize _grp1List", "count _arr", or "selectRandom _nearEntities"
            const firstTokenMatch = trimmed.match(/^([a-zA-Z0-9_]+)\b/);
            if (firstTokenMatch) {
                const cmdLower = firstTokenMatch[1].toLowerCase();
                if (cmdLower === 'selectrandom') {
                    const rest = trimmed.slice(firstTokenMatch[0].length).trim();
                    const elem = this.inferArrayElementType(rest, knownVars, nativeCommands, activeIndexer, filePath);
                    if (elem && elem !== 'Any') {
                        return elem;
                    }
                }
                const elemType = this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES[cmdLower];
                if (elemType) {
                    return `Array<${elemType}>`;
                }

                const firstCmd = nativeCommands.getCommand(firstTokenMatch[1]);
                if (firstCmd && firstCmd.syntaxes) {
                    const unarySyn = firstCmd.syntaxes.find(s => s.callType === 'unary');
                    if (unarySyn && unarySyn.returnType && unarySyn.returnType !== 'Nothing') {
                        return unarySyn.returnType;
                    }
                }
            }

            // 3. Check if entire expression is a command, e.g. "createHashMap" or "allUnits"
            const cmdLower = trimmed.toLowerCase();
            const elemType = this.KNOWN_COMMAND_ARRAY_ELEMENT_TYPES[cmdLower];
            if (elemType) {
                return `Array<${elemType}>`;
            }

            const cmd = nativeCommands.getCommand(trimmed);
            if (cmd && cmd.returnType && cmd.returnType !== 'Nothing') {
                return cmd.returnType;
            }
        }

        return 'Any';
    }

    /**
     * Check if a provided type matches an expected type (supports union types like "Array | String")
     */
    public static isTypeCompatible(provided: string, expected: string): boolean {
        if (!expected || expected === 'Any' || !provided || provided === 'Any') {
            return true;
        }

        // Handle union types in provided: e.g. "Array | String"
        if (provided.includes(' | ')) {
            return provided.split(' | ').some(t => this.isTypeCompatible(t.trim(), expected));
        }

        // Handle union types in expected: e.g. "Number | Control"
        if (expected.includes(' | ')) {
            return expected.split(' | ').some(t => this.isTypeCompatible(provided, t.trim()));
        }

        let p = provided.toLowerCase();
        let e = expected.toLowerCase();

        if (p === 'hashmapunknown') p = 'hashmap';
        if (e === 'hashmapunknown') e = 'hashmap';

        if (p === e) return true;
        if (p.startsWith('array') && e.startsWith('array')) {
            const pElem = (p.match(/^array<(.+)>$/i) || p.match(/^array\s+of\s+(.+)$/i))?.[1]?.trim();
            const eElem = (e.match(/^array<(.+)>$/i) || e.match(/^array\s+of\s+(.+)$/i))?.[1]?.trim();
            if (!pElem || !eElem || pElem.toLowerCase() === 'any' || eElem.toLowerCase() === 'any') return true;
            return this.isTypeCompatible(pElem, eElem);
        }
        if (e === 'array' && p.startsWith('array')) return true;
        if (p === 'array' && e.startsWith('array')) return true;
        if (e === 'number' && (p === 'scalar' || p === 'number')) return true;
        if (p === 'number' && (e === 'scalar' || e === 'number')) return true;
        if (e === 'boolean' && (p === 'bool' || p === 'boolean')) return true;
        if (p === 'boolean' && (e === 'bool' || e === 'boolean')) return true;
        // Waypoint <-> Array compatibility (SQF waypoints are represented as [group, index] arrays)
        if (p === 'waypoint' && (e === 'array' || e.startsWith('array'))) return true;
        if (e === 'waypoint' && (p === 'array' || p.startsWith('array'))) return true;
        const isPosP = this.isPositionType(p);
        const isPosE = this.isPositionType(e);
        if (isPosP && isPosE) return true;
        if (isPosP && (e === 'array' || e.startsWith('array'))) return true;
        if (isPosE && (p === 'array' || p.startsWith('array'))) return true;

        return false;
    }

    /**
     * Checks if an expression matches a Vector3d (3-element array of numbers [x, y, z]).
     * Arma 3 has no engine Vector3d type; it is an ARRAY of 3 numbers.
     */
    public static checkVector3d(
        expr: string,
        knownVars?: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager,
        indexer?: WorkspaceIndexer,
        filePath?: string
    ): { isValid: boolean; reason?: string } {
        let trimmed = expr.trim();
        if (!trimmed) {
            return { isValid: true };
        }

        if (this.isFullyEnclosed(trimmed)) {
            trimmed = trimmed.slice(1, -1).trim();
        }

        // 1. Array literal: [ ... ]
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            const inner = trimmed.slice(1, -1).trim();
            if (!inner) {
                return { isValid: false, reason: "Expected a 3-element array of numbers [x, y, z], but got empty array []" };
            }
            const elements = this.splitTopLevel(inner);
            if (elements.length !== 3) {
                return { 
                    isValid: false, 
                    reason: `Expected a 3-element array of numbers [x, y, z], but got ${elements.length} element(s)` 
                };
            }
            for (let i = 0; i < elements.length; i++) {
                const elem = elements[i].trim();
                const elemType = this.inferExpressionType(elem, knownVars || new Map(), nativeCommands, indexer, filePath);
                if (elemType !== 'Any' && elemType !== 'Number' && elemType.toLowerCase() !== 'scalar') {
                    return { 
                        isValid: false, 
                        reason: `Element ${i} ('${elem}') in Vector3d is of type '${elemType}', expected Number` 
                    };
                }
            }
            return { isValid: true };
        }

        // 2. Variable reference: _var
        if (trimmed.startsWith('_') && /^[a-zA-Z0-9_]+$/.test(trimmed)) {
            if (knownVars) {
                const varInfo = knownVars.get(trimmed.toLowerCase());
                if (varInfo) {
                    if (varInfo.type !== 'Any' && !this.isTypeCompatible(varInfo.type, 'Array') && !this.isPositionType(varInfo.type)) {
                        return { 
                            isValid: false, 
                            reason: `Variable '${trimmed}' has type '${varInfo.type}', expected position or 3-element array of numbers [x, y, z]` 
                        };
                    }
                    if (varInfo.declarationText) {
                        // Check assignment to an array literal: _var = [ ... ];
                        const assignMatch = varInfo.declarationText.match(/=\s*(\[[^;]*\])\s*;?/);
                        if (assignMatch) {
                            const arrText = assignMatch[1].trim();
                            const inner = arrText.slice(1, -1).trim();
                            if (!inner) {
                                return { isValid: false, reason: `Variable '${trimmed}' was initialized as an empty array, expected 3-element array of numbers [x, y, z]` };
                            }
                            const elements = this.splitTopLevel(inner);
                            if (elements.length !== 3) {
                                return { 
                                    isValid: false, 
                                    reason: `Variable '${trimmed}' was assigned a ${elements.length}-element array, expected 3-element array of numbers [x, y, z]` 
                                };
                            }
                            for (let i = 0; i < elements.length; i++) {
                                const elem = elements[i].trim();
                                const elemType = this.inferExpressionType(elem, knownVars, nativeCommands, indexer, filePath);
                                if (elemType !== 'Any' && elemType !== 'Number' && elemType.toLowerCase() !== 'scalar') {
                                    return { 
                                        isValid: false, 
                                        reason: `Element ${i} in variable '${trimmed}' is of type '${elemType}', expected Number` 
                                    };
                                }
                            }
                        }
                        // Check params statement: ["_var", [0, 0, 0], [[]], 3]
                        const paramMatch = varInfo.declarationText.match(/\[\s*["'](_[a-zA-Z0-9_]+)["']\s*,\s*(\[[^\]]*\])?\s*(?:,\s*(\[[^\]]*\])\s*(?:,\s*(\d+))?)?/);
                        if (paramMatch && paramMatch[4]) {
                            const count = parseInt(paramMatch[4], 10);
                            if (count !== 3) {
                                return {
                                    isValid: false,
                                    reason: `Parameter '${trimmed}' expects ${count} elements, but Vector3d requires 3 elements`
                                };
                            }
                        }
                    }
                }
            }
            return { isValid: true };
        }

        // 3. General expression or command call
        const inferred = this.inferExpressionType(trimmed, knownVars || new Map(), nativeCommands, indexer, filePath);
        if (inferred === 'Any' || this.isTypeCompatible(inferred, 'Array') || this.isPositionType(inferred)) {
            return { isValid: true };
        }

        return { 
            isValid: false, 
            reason: `Expression has type '${inferred}', expected 3-element array of numbers [x, y, z]` 
        };
    }

    /**
     * Checks if an argument expression meets the requirements of the expected parameter type.
     */
    public static checkArgument(
        expr: string | undefined,
        inferredType: string,
        expectedType: string,
        knownVars?: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager,
        indexer?: WorkspaceIndexer,
        filePath?: string
    ): { isValid: boolean; reason?: string } {
        if (!expectedType || expectedType === 'Any' || !inferredType || inferredType === 'Any') {
            return { isValid: true };
        }

        const expLower = expectedType.toLowerCase();
        const isVector = this.isPositionType(expLower);

        if (isVector) {
            if (expr) {
                return this.checkVector3d(expr, knownVars, nativeCommands, indexer, filePath);
            }
            const ok = this.isTypeCompatible(inferredType, 'Array') || this.isPositionType(inferredType);
            return { 
                isValid: ok, 
                reason: ok ? undefined : `Type '${inferredType}' is not a valid position or 3-element array` 
            };
        }

        const ok = this.isTypeCompatible(inferredType, expectedType);
        return {
            isValid: ok,
            reason: ok ? undefined : `Type '${inferredType}' is not compatible with expected '${expectedType}'`
        };
    }

    /**
     * Convenience boolean check for argument compatibility.
     */
    public static isArgumentCompatible(
        expr: string | undefined,
        inferredType: string,
        expectedType: string,
        knownVars?: Map<string, InferredVariable>,
        nativeCommands?: NativeCommandsManager,
        indexer?: WorkspaceIndexer,
        filePath?: string
    ): boolean {
        return this.checkArgument(expr, inferredType, expectedType, knownVars, nativeCommands, indexer, filePath).isValid;
    }

    /**
     * Extract the left-hand operand expression before a command on a line.
     */
    public static extractLeftOperand(lineText: string, cmdIndex: number): string | undefined {
        const before = lineText.slice(0, cmdIndex);
        if (!before.trim()) return undefined;

        const trimmedBefore = before.trim();
        const lastChar = trimmedBefore[trimmedBefore.length - 1];
        if ([';', '{', '(', '[', ',', '=', '+', '-', '*', '/', '!', '>', '<', '&', '|'].includes(lastChar)) {
            return undefined;
        }

        let depthParen = 0;
        let depthBracket = 0;
        let depthBrace = 0;
        let inString = false;
        let quoteChar = '';

        // First pass: find target depths at the end of before (right before the command)
        for (let i = 0; i < before.length; i++) {
            const ch = before[i];
            if (inString) {
                if (ch === quoteChar) {
                    if (before[i + 1] === quoteChar) {
                        i++; // Escaped quote ("" or '')
                    } else {
                        inString = false;
                    }
                }
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '(') depthParen++;
            else if (ch === ')') depthParen = Math.max(0, depthParen - 1);
            else if (ch === '[') depthBracket++;
            else if (ch === ']') depthBracket = Math.max(0, depthBracket - 1);
            else if (ch === '{') depthBrace++;
            else if (ch === '}') depthBrace = Math.max(0, depthBrace - 1);
        }

        const targetParen = depthParen;
        const targetBracket = depthBracket;
        const targetBrace = depthBrace;

        // Second pass: scan forward to find the start of the operand expression
        depthParen = 0;
        depthBracket = 0;
        depthBrace = 0;
        inString = false;
        quoteChar = '';
        let lastDelimEnd = 0;

        const CONTROL_KEYWORDS = new Set([
            'exitwith', 'then', 'else', 'do', 'while', 'waituntil',
            'return', 'with', 'case', 'default'
        ]);

        for (let i = 0; i < before.length; i++) {
            const ch = before[i];
            if (inString) {
                if (ch === quoteChar) {
                    if (before[i + 1] === quoteChar) {
                        i++;
                    } else {
                        inString = false;
                    }
                }
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }

            const atTarget = (depthParen === targetParen && depthBracket === targetBracket && depthBrace === targetBrace);

            if (ch === '(') {
                depthParen++;
                if (depthParen === targetParen && depthBracket === targetBracket && depthBrace === targetBrace) {
                    lastDelimEnd = i + 1;
                }
                continue;
            }
            if (ch === ')') { depthParen = Math.max(0, depthParen - 1); continue; }
            if (ch === '[') {
                depthBracket++;
                if (depthParen === targetParen && depthBracket === targetBracket && depthBrace === targetBrace) {
                    lastDelimEnd = i + 1;
                }
                continue;
            }
            if (ch === ']') { depthBracket = Math.max(0, depthBracket - 1); continue; }
            if (ch === '{') {
                depthBrace++;
                if (depthParen === targetParen && depthBracket === targetBracket && depthBrace === targetBrace) {
                    lastDelimEnd = i + 1;
                }
                continue;
            }
            if (ch === '}') { depthBrace = Math.max(0, depthBrace - 1); continue; }

            if (atTarget) {
                if (ch === ';' || ch === '=' || ch === ',') {
                    lastDelimEnd = i + 1;
                } else if ((ch === '&' && before[i + 1] === '&') || (ch === '|' && before[i + 1] === '|')) {
                    lastDelimEnd = i + 2;
                    i++;
                } else if (ch === '!' && before[i + 1] === '=') {
                    lastDelimEnd = i + 2;
                    i++;
                } else if ((ch === '<' || ch === '>') && before[i + 1] === '=') {
                    lastDelimEnd = i + 2;
                    i++;
                } else if (ch === '<' || ch === '>') {
                    lastDelimEnd = i + 1;
                } else if (/[a-zA-Z_]/.test(ch)) {
                    if (i === 0 || !/[a-zA-Z0-9_]/.test(before[i - 1])) {
                        let wEnd = i;
                        while (wEnd < before.length && /[a-zA-Z0-9_]/.test(before[wEnd])) wEnd++;
                        const word = before.slice(i, wEnd).toLowerCase();
                        if (CONTROL_KEYWORDS.has(word)) {
                            lastDelimEnd = wEnd;
                            i = wEnd - 1;
                        }
                    }
                }
            }
        }

        const res = before.slice(lastDelimEnd).trim();
        return res || undefined;
    }

    /**
     * Extract the right-hand operand expression after a command on a line.
     */
    public static extractRightOperand(lineText: string, cmdEndIndex: number): string | undefined {
        const after = lineText.slice(cmdEndIndex).trim().replace(/;$/, '');
        if (!after) return undefined;

        // If starts with '(', extract until matching ')'
        if (after.startsWith('(')) {
            let depth = 0;
            for (let i = 0; i < after.length; i++) {
                if (after[i] === '(') depth++;
                else if (after[i] === ')') {
                    depth--;
                    if (depth === 0) {
                        return after.slice(0, i + 1);
                    }
                }
            }
        }

        // If starts with '[', extract until matching ']'
        if (after.startsWith('[')) {
            let depth = 0;
            for (let i = 0; i < after.length; i++) {
                if (after[i] === '[') depth++;
                else if (after[i] === ']') {
                    depth--;
                    if (depth === 0) {
                        return after.slice(0, i + 1);
                    }
                }
            }
        }

        // If starts with '{', extract until matching '}'
        if (after.startsWith('{')) {
            let depth = 0;
            for (let i = 0; i < after.length; i++) {
                if (after[i] === '{') depth++;
                else if (after[i] === '}') {
                    depth--;
                    if (depth === 0) {
                        return after.slice(0, i + 1);
                    }
                }
            }
            return after;
        }

        // Otherwise grab first token
        const tokenMatch = after.match(/^([_a-zA-Z0-9]+|"[^"]*"|'[^']*')/);
        if (tokenMatch) {
            return tokenMatch[1];
        }

        return after;
    }
}
