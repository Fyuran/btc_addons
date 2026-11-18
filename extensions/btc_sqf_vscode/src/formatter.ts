import * as vscode from 'vscode';
import { NativeCommandsManager } from './nativeCommands';
import { WorkspaceIndexer } from './workspaceIndexer';

export type BraceStyle = '1tbs' | 'allman' | 'stroustrup' | 'whitesmiths';

export interface SqfFormatterOptions {
    braceStyle: BraceStyle;
    correctCasing: boolean;
    keepOneLineBlocks: boolean;
    tabSize: number;
    insertSpaces: boolean;
    maxEmptyLines: number;
}

export enum TokenType {
    Whitespace = 'Whitespace',
    Newline = 'Newline',
    LineComment = 'LineComment',
    BlockComment = 'BlockComment',
    Preprocessor = 'Preprocessor',
    String = 'String',
    Word = 'Word',
    Number = 'Number',
    OpenBrace = 'OpenBrace',
    CloseBrace = 'CloseBrace',
    OpenBracket = 'OpenBracket',
    CloseBracket = 'CloseBracket',
    OpenParen = 'OpenParen',
    CloseParen = 'CloseParen',
    Semicolon = 'Semicolon',
    Comma = 'Comma',
    Colon = 'Colon',
    Operator = 'Operator'
}

export interface Token {
    type: TokenType;
    text: string;
    line: number;
    col: number;
    isSingleLine?: boolean;
    matching?: Token;
    hasPrecedingBlankLine?: boolean;
    isTrailingComment?: boolean;
    isUnaryOp?: boolean;
    isMacroCall?: boolean;
    isSymbolMacro?: boolean;
}

const cbaStandardFunctions = new Map<string, string>([
    ['cba_fnc_waitandexecute', 'CBA_fnc_waitAndExecute'],
    ['cba_fnc_waituntilandexec', 'CBA_fnc_waitUntilAndExec'],
    ['cba_fnc_addeventhandler', 'CBA_fnc_addEventHandler'],
    ['cba_fnc_removeeventhandler', 'CBA_fnc_removeEventHandler'],
    ['cba_fnc_addperframehandler', 'CBA_fnc_addPerFrameHandler'],
    ['cba_fnc_removeperframehandler', 'CBA_fnc_removePerFrameHandler'],
    ['cba_fnc_globalevent', 'CBA_fnc_globalEvent'],
    ['cba_fnc_serverevent', 'CBA_fnc_serverEvent'],
    ['cba_fnc_localevent', 'CBA_fnc_localEvent'],
    ['cba_fnc_targetevent', 'CBA_fnc_targetEvent'],
    ['cba_fnc_customevent', 'CBA_fnc_customEvent'],
    ['cba_fnc_hashset', 'CBA_fnc_hashSet'],
    ['cba_fnc_hashget', 'CBA_fnc_hashGet'],
    ['cba_fnc_hashcreate', 'CBA_fnc_hashCreate'],
    ['cba_fnc_hashrem', 'CBA_fnc_hashRem'],
    ['cba_fnc_hasheach', 'CBA_fnc_hashEach'],
    ['cba_fnc_hashhas', 'CBA_fnc_hashHas'],
    ['cba_fnc_hashkeys', 'CBA_fnc_hashKeys'],
    ['cba_fnc_hashvalues', 'CBA_fnc_hashValues'],
    ['cba_fnc_directcall', 'CBA_fnc_directCall'],
    ['cba_fnc_getpos', 'CBA_fnc_getPos'],
    ['cba_fnc_setpos', 'CBA_fnc_setPos'],
    ['cba_fnc_createnamespace', 'CBA_fnc_createNamespace'],
    ['cba_fnc_deletenamespace', 'CBA_fnc_deleteNamespace']
]);

const cbaMacros = new Set<string>([
    'func', 'efunc', 'qfunc', 'qefunc', 'gvar', 'egvar', 'qgvar', 'qegvar',
    'quote', 'prep', 'prep_folder', 'doubles', 'triples', 'pathtof', 'qpathtof',
    'arr_1', 'arr_2', 'arr_3', 'arr_4', 'arr_5', 'arr_6', 'arr_7', 'arr_8'
]);

export class SqfTokenizer {
    public static tokenize(text: string): Token[] {
        const tokens: Token[] = [];
        const len = text.length;
        let i = 0;
        let line = 0;
        let col = 0;

        while (i < len) {
            const ch = text[i];
            const next = i + 1 < len ? text[i + 1] : '';

            // Newline
            if (ch === '\r' && next === '\n') {
                tokens.push({ type: TokenType.Newline, text: '\r\n', line, col });
                i += 2;
                line++;
                col = 0;
                continue;
            }
            if (ch === '\n') {
                tokens.push({ type: TokenType.Newline, text: '\n', line, col });
                i++;
                line++;
                col = 0;
                continue;
            }

            // Whitespace (spaces, tabs)
            if (ch === ' ' || ch === '\t') {
                const startCol = col;
                let ws = '';
                while (i < len && (text[i] === ' ' || text[i] === '\t')) {
                    ws += text[i];
                    i++;
                    col++;
                }
                tokens.push({ type: TokenType.Whitespace, text: ws, line, col: startCol });
                continue;
            }

            // Line comment //
            if (ch === '/' && next === '/') {
                const startCol = col;
                let comment = '';
                while (i < len && text[i] !== '\n' && text[i] !== '\r') {
                    comment += text[i];
                    i++;
                    col++;
                }
                tokens.push({ type: TokenType.LineComment, text: comment, line, col: startCol });
                continue;
            }

            // Block comment /* ... */
            if (ch === '/' && next === '*') {
                const startLine = line;
                const startCol = col;
                let comment = '/*';
                i += 2;
                col += 2;
                while (i < len && !(text[i] === '*' && i + 1 < len && text[i + 1] === '/')) {
                    comment += text[i];
                    if (text[i] === '\n') {
                        line++;
                        col = 0;
                    } else {
                        col++;
                    }
                    i++;
                }
                if (i < len) {
                    comment += '*/';
                    i += 2;
                    col += 2;
                }
                tokens.push({ type: TokenType.BlockComment, text: comment, line: startLine, col: startCol });
                continue;
            }

            // Preprocessor directive: # at start of line or preceded only by whitespace
            if (ch === '#') {
                let isLineStart = true;
                for (let k = tokens.length - 1; k >= 0; k--) {
                    if (tokens[k].type === TokenType.Newline) break;
                    if (tokens[k].type !== TokenType.Whitespace) {
                        isLineStart = false;
                        break;
                    }
                }

                if (isLineStart) {
                    const startLine = line;
                    const startCol = col;
                    let prep = '';
                    while (i < len) {
                        if (text[i] === '\\' && i + 1 < len && (text[i + 1] === '\n' || text[i + 1] === '\r')) {
                            prep += text[i];
                            i++;
                            if (text[i] === '\r' && i + 1 < len && text[i + 1] === '\n') {
                                prep += '\r\n';
                                i += 2;
                                line++;
                                col = 0;
                            } else if (text[i] === '\n') {
                                prep += '\n';
                                i++;
                                line++;
                                col = 0;
                            }
                            continue;
                        }
                        if (text[i] === '\n' || text[i] === '\r') {
                            break;
                        }
                        prep += text[i];
                        i++;
                        col++;
                    }
                    tokens.push({ type: TokenType.Preprocessor, text: prep, line: startLine, col: startCol });
                    continue;
                }
            }

            // Double quoted string "..." in SQF (escaped ONLY by "")
            if (ch === '"') {
                const startLine = line;
                const startCol = col;
                let str = '"';
                i++;
                col++;
                while (i < len) {
                    if (text[i] === '"') {
                        if (i + 1 < len && text[i + 1] === '"') {
                            str += '""';
                            i += 2;
                            col += 2;
                            continue;
                        } else {
                            str += '"';
                            i++;
                            col++;
                            break;
                        }
                    }
                    if (text[i] === '\n') {
                        line++;
                        col = 0;
                    } else {
                        col++;
                    }
                    str += text[i];
                    i++;
                }
                tokens.push({ type: TokenType.String, text: str, line: startLine, col: startCol });
                continue;
            }

            // Single quoted string '...' in SQF (escaped ONLY by '')
            if (ch === "'") {
                const startLine = line;
                const startCol = col;
                let str = "'";
                i++;
                col++;
                while (i < len) {
                    if (text[i] === "'") {
                        if (i + 1 < len && text[i + 1] === "'") {
                            str += "''";
                            i += 2;
                            col += 2;
                            continue;
                        } else {
                            str += "'";
                            i++;
                            col++;
                            break;
                        }
                    }
                    if (text[i] === '\n') {
                        line++;
                        col = 0;
                    } else {
                        col++;
                    }
                    str += text[i];
                    i++;
                }
                tokens.push({ type: TokenType.String, text: str, line: startLine, col: startCol });
                continue;
            }

            // Delimiters
            if (ch === '{') { tokens.push({ type: TokenType.OpenBrace, text: '{', line, col }); i++; col++; continue; }
            if (ch === '}') { tokens.push({ type: TokenType.CloseBrace, text: '}', line, col }); i++; col++; continue; }
            if (ch === '[') { tokens.push({ type: TokenType.OpenBracket, text: '[', line, col }); i++; col++; continue; }
            if (ch === ']') { tokens.push({ type: TokenType.CloseBracket, text: ']', line, col }); i++; col++; continue; }
            if (ch === '(') { tokens.push({ type: TokenType.OpenParen, text: '(', line, col }); i++; col++; continue; }
            if (ch === ')') { tokens.push({ type: TokenType.CloseParen, text: ')', line, col }); i++; col++; continue; }
            if (ch === ';') { tokens.push({ type: TokenType.Semicolon, text: ';', line, col }); i++; col++; continue; }
            if (ch === ',') { tokens.push({ type: TokenType.Comma, text: ',', line, col }); i++; col++; continue; }
            if (ch === ':') { tokens.push({ type: TokenType.Colon, text: ':', line, col }); i++; col++; continue; }

            // Two-character operators
            const twoChar = ch + next;
            if (['==', '!=', '<=', '>=', '&&', '||', '>>'].includes(twoChar)) {
                tokens.push({ type: TokenType.Operator, text: twoChar, line, col });
                i += 2;
                col += 2;
                continue;
            }

            // Single-character operators
            if (['=', '+', '-', '*', '/', '%', '^', '!', '<', '>', '&', '|', '#'].includes(ch)) {
                tokens.push({ type: TokenType.Operator, text: ch, line, col });
                i++;
                col++;
                continue;
            }

            // Numbers (e.g. 123, 0.5, 0xFF, 1e-3)
            if (/[0-9]/.test(ch) || (ch === '.' && /[0-9]/.test(next))) {
                const startCol = col;
                let num = '';
                if (ch === '0' && (next === 'x' || next === 'X')) {
                    num += ch + next;
                    i += 2;
                    col += 2;
                    while (i < len && /[0-9a-fA-F]/.test(text[i])) {
                        num += text[i];
                        i++;
                        col++;
                    }
                } else {
                    while (i < len && /[0-9a-zA-Z_.]/.test(text[i])) {
                        num += text[i];
                        i++;
                        col++;
                    }
                }
                tokens.push({ type: TokenType.Number, text: num, line, col: startCol });
                continue;
            }

            // Identifiers / Words
            if (/[a-zA-Z_]/.test(ch)) {
                const startCol = col;
                let word = '';
                while (i < len && /[a-zA-Z0-9_]/.test(text[i])) {
                    word += text[i];
                    i++;
                    col++;
                }
                tokens.push({ type: TokenType.Word, text: word, line, col: startCol });
                continue;
            }

            tokens.push({ type: TokenType.Operator, text: ch, line, col });
            i++;
            col++;
        }

        return tokens;
    }
}

export class SqfFormatter implements vscode.DocumentFormattingEditProvider, vscode.DocumentRangeFormattingEditProvider {
    constructor(
        private nativeCommands?: NativeCommandsManager,
        private indexer?: WorkspaceIndexer
    ) {}

    public formatDocument(
        document: vscode.TextDocument,
        options: vscode.FormattingOptions
    ): vscode.TextEdit[] {
        const config = vscode.workspace.getConfiguration('btcSqf');
        if (!config.get<boolean>('formatting.enable', true)) {
            return [];
        }

        const braceStyle = config.get<BraceStyle>('formatting.braceStyle', '1tbs');
        const correctCasing = config.get<boolean>('formatting.correctCasing', true);
        const keepOneLineBlocks = config.get<boolean>('formatting.keepOneLineBlocks', true);
        const maxEmptyLines = config.get<number>('formatting.maxEmptyLines', 1);

        const formatterOptions: SqfFormatterOptions = {
            braceStyle,
            correctCasing,
            keepOneLineBlocks,
            tabSize: options.tabSize,
            insertSpaces: options.insertSpaces,
            maxEmptyLines
        };

        const originalText = document.getText();
        const formattedText = this.formatText(originalText, formatterOptions);

        if (formattedText === originalText) {
            return [];
        }

        const fullRange = new vscode.Range(
            document.positionAt(0),
            document.positionAt(originalText.length)
        );

        return [vscode.TextEdit.replace(fullRange, formattedText)];
    }

    public provideDocumentFormattingEdits(
        document: vscode.TextDocument,
        options: vscode.FormattingOptions,
        token: vscode.CancellationToken
    ): vscode.TextEdit[] {
        return this.formatDocument(document, options);
    }

    public provideDocumentRangeFormattingEdits(
        document: vscode.TextDocument,
        range: vscode.Range,
        options: vscode.FormattingOptions,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.TextEdit[]> {
        const config = vscode.workspace.getConfiguration('btcSqf');
        if (!config.get<boolean>('formatting.enable', true)) {
            return [];
        }

        const braceStyle = config.get<BraceStyle>('formatting.braceStyle', '1tbs');
        const correctCasing = config.get<boolean>('formatting.correctCasing', true);
        const keepOneLineBlocks = config.get<boolean>('formatting.keepOneLineBlocks', true);
        const maxEmptyLines = config.get<number>('formatting.maxEmptyLines', 1);

        const formatterOptions: SqfFormatterOptions = {
            braceStyle,
            correctCasing,
            keepOneLineBlocks,
            tabSize: options.tabSize,
            insertSpaces: options.insertSpaces,
            maxEmptyLines
        };

        // Format whole lines covering the range
        const startLine = document.lineAt(range.start.line);
        const endLine = document.lineAt(range.end.line);
        const rangeToFormat = new vscode.Range(startLine.range.start, endLine.range.end);
        const originalText = document.getText(rangeToFormat);
        const formattedText = this.formatText(originalText, formatterOptions);

        if (formattedText === originalText) {
            return [];
        }

        return [vscode.TextEdit.replace(rangeToFormat, formattedText)];
    }

    public formatText(text: string, options: SqfFormatterOptions): string {
        const allTokens = SqfTokenizer.tokenize(text);
        if (allTokens.length === 0) return '';

        // 1. Filter significant tokens & record blank lines
        const sigTokens: Token[] = [];
        let prevSigLine = -1;

        for (let i = 0; i < allTokens.length; i++) {
            const t = allTokens[i];
            if (t.type === TokenType.Whitespace || t.type === TokenType.Newline) {
                continue;
            }

            if (prevSigLine !== -1 && (t.line - prevSigLine) >= 2) {
                t.hasPrecedingBlankLine = true;
            } else {
                t.hasPrecedingBlankLine = false;
            }

            if (prevSigLine !== -1 && t.line === prevSigLine && (t.type === TokenType.LineComment || t.type === TokenType.BlockComment)) {
                t.isTrailingComment = true;
            } else {
                t.isTrailingComment = false;
            }

            prevSigLine = t.line;
            sigTokens.push(t);
        }

        // 2. Correct casing for native commands and workspace/CBA functions
        if (options.correctCasing) {
            for (const t of sigTokens) {
                if (t.type === TokenType.Word) {
                    if (t.text.startsWith('_')) {
                        // Local variable: never alter
                        continue;
                    }
                    const lower = t.text.toLowerCase();
                    if (cbaMacros.has(lower)) {
                        t.text = t.text.toUpperCase();
                    } else if (this.nativeCommands && this.nativeCommands.hasCommand(lower)) {
                        const cmdInfo = this.nativeCommands.getCommand(lower);
                        if (cmdInfo) {
                            t.text = cmdInfo.name;
                        }
                    } else if (cbaStandardFunctions.has(lower)) {
                        t.text = cbaStandardFunctions.get(lower)!;
                    } else if (this.indexer) {
                        const fn = this.indexer.getFunction(t.text);
                        if (fn) {
                            if (fn.fullName.toLowerCase() === lower) {
                                t.text = fn.fullName;
                            } else if (fn.shortName.toLowerCase() === lower) {
                                t.text = fn.shortName;
                            }
                        }
                    }
                }
            }
        }

        // 3. Match brackets and determine single-line blocks
        const braceStack: Token[] = [];
        const bracketStack: Token[] = [];
        const parenStack: Token[] = [];

        for (let i = 0; i < sigTokens.length; i++) {
            const t = sigTokens[i];
            if (t.type === TokenType.OpenBrace) {
                braceStack.push(t);
            } else if (t.type === TokenType.CloseBrace && braceStack.length > 0) {
                const open = braceStack.pop()!;
                open.matching = t;
                t.matching = open;
                const isSingleLine = (open.line === t.line);
                open.isSingleLine = isSingleLine;
                t.isSingleLine = isSingleLine;
            } else if (t.type === TokenType.OpenBracket) {
                bracketStack.push(t);
            } else if (t.type === TokenType.CloseBracket && bracketStack.length > 0) {
                const open = bracketStack.pop()!;
                open.matching = t;
                t.matching = open;
                const isSingleLine = (open.line === t.line);
                open.isSingleLine = isSingleLine;
                t.isSingleLine = isSingleLine;
            } else if (t.type === TokenType.OpenParen) {
                const prev = i > 0 ? sigTokens[i - 1] : null;
                let isMacro = false;
                let isSymbolMacro = false;
                if (prev && prev.type === TokenType.Word) {
                    const lower = prev.text.toLowerCase();
                    const upper = prev.text.toUpperCase();
                    if (
                        cbaMacros.has(lower) ||
                        prev.text.endsWith('FUNC') ||
                        prev.text.endsWith('GVAR') ||
                        prev.text.endsWith('PREP') ||
                        prev.text.endsWith('DOUBLES') ||
                        prev.text.endsWith('TRIPLES') ||
                        prev.text.endsWith('PATHTOF') ||
                        (prev.text.length > 1 && prev.text === upper)
                    ) {
                        isMacro = true;
                        if (lower !== 'quote') {
                            isSymbolMacro = true;
                        }
                    }
                }
                t.isMacroCall = isMacro;
                t.isSymbolMacro = isSymbolMacro;
                parenStack.push(t);
            } else if (t.type === TokenType.CloseParen && parenStack.length > 0) {
                const open = parenStack.pop()!;
                open.matching = t;
                t.matching = open;
                const isSingleLine = (open.line === t.line);
                open.isSingleLine = isSingleLine;
                t.isSingleLine = isSingleLine;
            }
        }

        // 4. Formatter layout
        const lines: string[] = [];
        let currentTokens: string[] = [];
        let currentIndent = 0;
        const indentUnit = options.insertSpaces ? ' '.repeat(options.tabSize) : '\t';

        const flushLine = (indentOverride?: number) => {
            if (currentTokens.length === 0) return;
            const lvl = indentOverride !== undefined ? indentOverride : currentIndent;
            const indentStr = indentUnit.repeat(Math.max(0, lvl));
            lines.push(indentStr + currentTokens.join(''));
            currentTokens = [];
        };

        const emitBlankLineIfNeeded = (t: Token) => {
            if (t && t.hasPrecedingBlankLine && lines.length > 0) {
                if (lines[lines.length - 1] !== '') {
                    lines.push('');
                }
            }
        };

        const isUnaryOp = (t: Token, prev: Token | null): boolean => {
            if (!t || t.type !== TokenType.Operator || (t.text !== '-' && t.text !== '+')) return false;
            if (!prev) return true;
            if (prev.type === TokenType.OpenParen || prev.type === TokenType.OpenBracket || prev.type === TokenType.OpenBrace) return true;
            if (prev.type === TokenType.Comma || prev.type === TokenType.Colon || prev.type === TokenType.Semicolon) return true;
            if (prev.type === TokenType.Operator) return true;
            if (prev.type === TokenType.Preprocessor) return true;
            if (prev.type === TokenType.Word && ['exitwith', 'return'].includes(prev.text.toLowerCase())) return true;
            return false;
        };

        interface ScopeItem {
            type: 'bracket' | 'brace' | 'paren';
            isSingleLine?: boolean;
            isMacroCall?: boolean;
            isSymbolMacro?: boolean;
        }
        const generalScopeStack: ScopeItem[] = [];

        const needSpace = (prev: Token | null, curr: Token): boolean => {
            if (!prev) return false;

            // Never add spaces inside symbol macros e.g. EFUNC(tools,debug), QGVAR(hq_call_%1)
            if (generalScopeStack.some(s => s.isSymbolMacro)) {
                return false;
            }

            // Empty brackets []
            if (prev.type === TokenType.OpenBracket && curr.type === TokenType.CloseBracket) return false;
            // Empty braces {}
            if (prev.type === TokenType.OpenBrace && curr.type === TokenType.CloseBrace) return false;

            if (curr.type === TokenType.Semicolon || curr.type === TokenType.Comma || curr.type === TokenType.Colon) return false;
            if (curr.type === TokenType.CloseParen || curr.type === TokenType.CloseBracket) return false;
            if (prev.type === TokenType.OpenParen || prev.type === TokenType.OpenBracket) return false;

            if (prev.type === TokenType.Operator && prev.text === '!') return false;
            if (prev.type === TokenType.Operator && prev.text === '#') return false;
            if (curr.type === TokenType.Operator && curr.text === '#') return false;

            // Unary - or +
            if (prev.isUnaryOp) {
                return false;
            }

            // Function/macro call: func(foo) vs native command with paren expression: vectorAdd (foo)
            if (curr.type === TokenType.OpenParen && prev.type === TokenType.Word) {
                const w = prev.text.toLowerCase();
                if (this.nativeCommands && this.nativeCommands.hasCommand(w)) {
                    return true;
                }
                return false;
            }

            if (curr.type === TokenType.OpenBrace) return true;
            if (prev.type === TokenType.OpenBrace) return true;
            if (curr.type === TokenType.CloseBrace) return true;

            // Space after comma: omit space if inside macro arguments e.g. EFUNC(tools,debug)
            if (prev.type === TokenType.Comma) {
                const topScope = generalScopeStack[generalScopeStack.length - 1];
                if (topScope && topScope.isMacroCall) {
                    return false;
                }
                return true;
            }

            if (prev.type === TokenType.Semicolon || prev.type === TokenType.Colon) return true;
            if (prev.type === TokenType.CloseParen || prev.type === TokenType.CloseBracket) return true;
            if (prev.type === TokenType.Operator || curr.type === TokenType.Operator) {
                return true;
            }
            return true;
        };

        const style = options.braceStyle;

        for (let i = 0; i < sigTokens.length; i++) {
            const t = sigTokens[i];
            const prev = i > 0 ? sigTokens[i - 1] : null;
            const next = i + 1 < sigTokens.length ? sigTokens[i + 1] : null;

            if (isUnaryOp(t, prev)) {
                t.isUnaryOp = true;
            }

            // Handle Preprocessor
            if (t.type === TokenType.Preprocessor) {
                flushLine();
                emitBlankLineIfNeeded(t);
                lines.push(indentUnit.repeat(currentIndent) + t.text);
                continue;
            }

            // Handle Trailing Comment
            if (t.isTrailingComment) {
                currentTokens.push(' ' + t.text);
                flushLine();
                continue;
            }

            // Handle Standalone Comment
            if (t.type === TokenType.LineComment || t.type === TokenType.BlockComment) {
                flushLine();
                emitBlankLineIfNeeded(t);
                lines.push(indentUnit.repeat(currentIndent) + t.text);
                continue;
            }

            emitBlankLineIfNeeded(t);

            // Handle Empty Braces {}
            if (t.type === TokenType.OpenBrace && next && next.type === TokenType.CloseBrace) {
                if (needSpace(prev, t) && currentTokens.length > 0) {
                    currentTokens.push(' ');
                }
                currentTokens.push('{}');
                i++; // skip CloseBrace
                continue;
            }

            // Handle Multi-line OpenBrace {
            if (t.type === TokenType.OpenBrace) {
                generalScopeStack.push({ type: 'brace', isSingleLine: t.isSingleLine });
                if (!t.isSingleLine || !options.keepOneLineBlocks) {
                    if (style === '1tbs' || style === 'stroustrup') {
                        if (currentTokens.length > 0) {
                            currentTokens.push(' {');
                            flushLine(currentIndent);
                        } else {
                            currentTokens.push('{');
                            flushLine(currentIndent);
                        }
                        currentIndent++;
                    } else if (style === 'allman') {
                        flushLine(currentIndent);
                        currentTokens.push('{');
                        flushLine(currentIndent);
                        currentIndent++;
                    } else if (style === 'whitesmiths') {
                        flushLine(currentIndent);
                        currentTokens.push('{');
                        flushLine(currentIndent + 1);
                        currentIndent++;
                    }
                    continue;
                }
            }

            // Handle Multi-line CloseBrace }
            if (t.type === TokenType.CloseBrace) {
                generalScopeStack.pop();
                if (!t.isSingleLine || !options.keepOneLineBlocks) {
                flushLine();
                currentIndent = Math.max(0, currentIndent - 1);

                const nextWord = (next && next.type === TokenType.Word) ? next.text.toLowerCase() : '';
                const isElseOrCatch = (nextWord === 'else' || nextWord === 'catch');
                const isIterationCmd = ['foreach', 'count', 'apply', 'select'].includes(nextWord);

                if (style === 'whitesmiths') {
                    currentTokens.push('}');
                    if (isElseOrCatch && next) {
                        flushLine(currentIndent + 1);
                        currentTokens.push(next.text);
                        i++;
                        const afterElse = i + 1 < sigTokens.length ? sigTokens[i + 1] : null;
                        if (afterElse && afterElse.type === TokenType.Word && afterElse.text.toLowerCase() === 'if') {
                            // Leave 'else if' to continue on same line
                        } else {
                            flushLine(currentIndent);
                        }
                    } else if (isIterationCmd && next) {
                        currentTokens.push(' ' + next.text);
                        i++;
                    } else if (next && (next.type === TokenType.Semicolon || next.type === TokenType.Comma)) {
                        currentTokens.push(next.text);
                        flushLine(currentIndent + 1);
                        i++;
                    } else {
                        flushLine(currentIndent + 1);
                    }
                } else if (style === '1tbs') {
                    currentTokens.push('}');
                    if (isElseOrCatch && next) {
                        currentTokens.push(' ' + next.text);
                        i++;
                        const afterElse = i + 1 < sigTokens.length ? sigTokens[i + 1] : null;
                        if (afterElse && afterElse.type === TokenType.OpenBrace && (!afterElse.isSingleLine || !options.keepOneLineBlocks)) {
                            currentTokens.push(' {');
                            flushLine(currentIndent);
                            currentIndent++;
                            i++;
                        }
                    } else if (isIterationCmd && next) {
                        currentTokens.push(' ' + next.text);
                        i++;
                    } else if (next && (next.type === TokenType.Semicolon || next.type === TokenType.Comma)) {
                        currentTokens.push(next.text);
                        flushLine(currentIndent);
                        i++;
                    } else {
                        flushLine(currentIndent);
                    }
                } else if (style === 'stroustrup') {
                    currentTokens.push('}');
                    if (isIterationCmd && next) {
                        currentTokens.push(' ' + next.text);
                        i++;
                    } else if (next && (next.type === TokenType.Semicolon || next.type === TokenType.Comma)) {
                        currentTokens.push(next.text);
                        flushLine(currentIndent);
                        i++;
                    } else {
                        flushLine(currentIndent);
                    }
                    if (isElseOrCatch && next) {
                        currentTokens.push(next.text);
                        i++;
                        const afterElse = i + 1 < sigTokens.length ? sigTokens[i + 1] : null;
                        if (afterElse && afterElse.type === TokenType.OpenBrace && (!afterElse.isSingleLine || !options.keepOneLineBlocks)) {
                            currentTokens.push(' {');
                            flushLine(currentIndent);
                            currentIndent++;
                            i++;
                        }
                    }
                } else if (style === 'allman') {
                    currentTokens.push('}');
                    if (isIterationCmd && next) {
                        currentTokens.push(' ' + next.text);
                        i++;
                    } else if (next && (next.type === TokenType.Semicolon || next.type === TokenType.Comma)) {
                        currentTokens.push(next.text);
                        flushLine(currentIndent);
                        i++;
                    } else {
                        flushLine(currentIndent);
                    }
                    if (isElseOrCatch && next) {
                        currentTokens.push(next.text);
                        i++;
                        const afterElse = i + 1 < sigTokens.length ? sigTokens[i + 1] : null;
                        if (afterElse && afterElse.type === TokenType.Word && afterElse.text.toLowerCase() === 'if') {
                            // else if continues on same line
                        } else {
                            flushLine(currentIndent);
                        }
                    }
                }
                continue;
            }
        }

            // Track Bracket stack for commas
            if (t.type === TokenType.OpenBracket) {
                generalScopeStack.push({ type: 'bracket', isSingleLine: t.isSingleLine });
                if (!t.isSingleLine) {
                    if (needSpace(prev, t) && currentTokens.length > 0) {
                        currentTokens.push(' ');
                    }
                    currentTokens.push('[');
                    flushLine(currentIndent);
                    currentIndent++;
                    continue;
                }
            }

            if (t.type === TokenType.CloseBracket) {
                generalScopeStack.pop();
                if (!t.isSingleLine) {
                    flushLine();
                    currentIndent = Math.max(0, currentIndent - 1);
                    currentTokens.push(']');
                    if (next && (next.type === TokenType.Semicolon || next.type === TokenType.Comma)) {
                        currentTokens.push(next.text);
                        i++;
                    }
                    flushLine(currentIndent);
                    continue;
                }
            }

            // Track Parentheses stack for macro calls
            if (t.type === TokenType.OpenParen) {
                generalScopeStack.push({ type: 'paren', isMacroCall: t.isMacroCall, isSymbolMacro: t.isSymbolMacro });
            }
            if (t.type === TokenType.CloseParen) {
                generalScopeStack.pop();
            }

            // Handle Comma inside multi-line bracket: ONLY if immediate enclosing scope is multi-line bracket!
            if (t.type === TokenType.Comma) {
                const isInsideMacro = generalScopeStack.some(s => s.isMacroCall);
                const topScope = generalScopeStack[generalScopeStack.length - 1];
                if (!isInsideMacro && topScope && topScope.type === 'bracket' && !topScope.isSingleLine) {
                    currentTokens.push(',');
                    flushLine(currentIndent);
                    continue;
                }
            }

            // Handle Semicolon ;
            if (t.type === TokenType.Semicolon) {
                currentTokens.push(';');
                const isInsideMacro = generalScopeStack.some(s => s.isMacroCall);
                if (!isInsideMacro) {
                    flushLine(currentIndent);
                }
                continue;
            }

            // Default token emission
            if (currentTokens.length > 0) {
                const lastTok = sigTokens[i - 1];
                if (needSpace(lastTok, t)) {
                    currentTokens.push(' ');
                }
            }

            currentTokens.push(t.text);
        }

        flushLine();

        return lines.join('\n') + '\n';
    }
}
