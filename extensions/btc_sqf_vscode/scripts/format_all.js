#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Parse CLI arguments
const args = process.argv.slice(2);
let braceStyle = '1tbs';
let targetDir = path.resolve(__dirname, '../../btc_toolchain');
let checkOnly = false;
let tabSize = 4;
let insertSpaces = true;

for (const arg of args) {
    if (arg.startsWith('--style=')) {
        braceStyle = arg.split('=')[1];
    } else if (arg.startsWith('--dir=')) {
        targetDir = path.resolve(arg.split('=')[1]);
    } else if (arg === '--check') {
        checkOnly = true;
    } else if (arg.startsWith('--tab-size=')) {
        tabSize = parseInt(arg.split('=')[1], 10) || 4;
    } else if (arg === '--tabs') {
        insertSpaces = false;
    }
}

// Ensure target directory exists
if (!fs.existsSync(targetDir)) {
    // Fallback to parent dir or current working dir
    targetDir = process.cwd();
}

console.log(`[BTC SQF] Formatting SQF files in: ${targetDir}`);
console.log(`[BTC SQF] Settings: braceStyle=${braceStyle}, tabSize=${tabSize}, spaces=${insertSpaces}`);

// Load native commands dictionary
const extensionPath = path.resolve(__dirname, '..');
const commandsPath = path.join(extensionPath, 'data', 'commands.json');
let nativeCommandsMap = new Map();

const sqfNonOperandWords = new Set([
    // Comparison & Logic
    'isnotequalto', 'isequalto', 'in', 'and', 'or', 'not',
    // Control flow
    'to', 'step', 'then', 'else', 'do', 'case', 'switch', 'while', 'until', 'waituntil',
    'for', 'from', 'foreach', 'with', 'assert', 'throw', 'catch', 'exitwith', 'return',
    // Array & Container operations
    'select', 'set', 'apply', 'find', 'count', 'resize', 'deleteat', 'pushback',
    'pushbackunique', 'append', 'splitstring', 'joinstring',
    // Code execution
    'call', 'spawn', 'execvm', 'canadd',
    // Scope & Variables
    'private', 'params', 'isnil', 'isnull',
    // Math & Vector
    'random', 'round', 'floor', 'ceil', 'abs', 'sqrt', 'sin', 'cos', 'tan',
    'asin', 'acos', 'atan', 'atan2', 'min', 'max', 'mod', 'vectormultiply',
    'vectordiff', 'vectoradd', 'vectorcrossproduct', 'vectordotproduct',
    'distance', 'distance2d', 'distancesqr', 'matrixmultiply'
]);

if (fs.existsSync(commandsPath)) {
    try {
        const raw = fs.readFileSync(commandsPath, 'utf-8').replace(/HashMapUnknown/g, 'HashMap');
        const parsed = JSON.parse(raw);
        for (const k of Object.keys(parsed)) {
            nativeCommandsMap.set(k.toLowerCase(), parsed[k]);
        }
        console.log(`[BTC SQF] Loaded ${nativeCommandsMap.size} native commands.`);
    } catch (err) {
        console.error('[BTC SQF] Failed to parse commands.json:', err);
    }
}

const cbaStandardFunctions = new Map([
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

const cbaMacros = new Set([
    'func', 'efunc', 'qfunc', 'qefunc', 'gvar', 'egvar', 'qgvar', 'qegvar',
    'quote', 'prep', 'prep_folder', 'doubles', 'triples', 'pathtof', 'qpathtof',
    'arr_1', 'arr_2', 'arr_3', 'arr_4', 'arr_5', 'arr_6', 'arr_7', 'arr_8'
]);

const TokenType = {
    Whitespace: 'Whitespace',
    Newline: 'Newline',
    LineComment: 'LineComment',
    BlockComment: 'BlockComment',
    Preprocessor: 'Preprocessor',
    String: 'String',
    Word: 'Word',
    Number: 'Number',
    OpenBrace: 'OpenBrace',
    CloseBrace: 'CloseBrace',
    OpenBracket: 'OpenBracket',
    CloseBracket: 'CloseBracket',
    OpenParen: 'OpenParen',
    CloseParen: 'CloseParen',
    Semicolon: 'Semicolon',
    Comma: 'Comma',
    Colon: 'Colon',
    Operator: 'Operator'
};

function tokenize(text) {
    const tokens = [];
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

        // Numbers
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

function formatSqf(text, options = {}) {
    const braceStyle = options.braceStyle || '1tbs';
    const correctCasing = options.correctCasing !== false;
    const keepOneLineBlocks = options.keepOneLineBlocks !== false;
    const tabSize = options.tabSize || 4;
    const insertSpaces = options.insertSpaces !== false;

    const allTokens = tokenize(text);
    if (allTokens.length === 0) return '';

    // 1. Filter significant tokens & record blank lines
    const sigTokens = [];
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

    // 2. Correct casing
    if (correctCasing) {
        for (const t of sigTokens) {
            if (t.type === TokenType.Word) {
                if (t.text.startsWith('_')) {
                    continue;
                }
                const lower = t.text.toLowerCase();
                if (cbaMacros.has(lower)) {
                    t.text = t.text.toUpperCase();
                } else if (nativeCommandsMap.has(lower)) {
                    const cmd = nativeCommandsMap.get(lower);
                    t.text = typeof cmd === 'string' ? cmd : cmd.name;
                } else if (cbaStandardFunctions.has(lower)) {
                    t.text = cbaStandardFunctions.get(lower);
                }
            }
        }
    }

    // 3. Match brackets and determine single-line blocks
    const braceStack = [];
    const bracketStack = [];
    const parenStack = [];

    for (let i = 0; i < sigTokens.length; i++) {
        const t = sigTokens[i];
        if (t.type === TokenType.OpenBrace) {
            braceStack.push(t);
        } else if (t.type === TokenType.CloseBrace && braceStack.length > 0) {
            const open = braceStack.pop();
            open.matching = t;
            t.matching = open;
            const isSingleLine = (open.line === t.line);
            open.isSingleLine = isSingleLine;
            t.isSingleLine = isSingleLine;
        } else if (t.type === TokenType.OpenBracket) {
            bracketStack.push(t);
        } else if (t.type === TokenType.CloseBracket && bracketStack.length > 0) {
            const open = bracketStack.pop();
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
            const open = parenStack.pop();
            open.matching = t;
            t.matching = open;
            const isSingleLine = (open.line === t.line);
            open.isSingleLine = isSingleLine;
            t.isSingleLine = isSingleLine;
        }
    }

    // 4. Formatter layout
    const lines = [];
    let currentTokens = [];
    let currentIndent = 0;
    const indentUnit = insertSpaces ? ' '.repeat(tabSize) : '\t';

    const flushLine = (indentOverride) => {
        if (currentTokens.length === 0) return;
        const lvl = indentOverride !== undefined ? indentOverride : currentIndent;
        const indentStr = indentUnit.repeat(Math.max(0, lvl));
        lines.push(indentStr + currentTokens.join(''));
        currentTokens = [];
    };

    const emitBlankLineIfNeeded = (t) => {
        if (t && t.hasPrecedingBlankLine && lines.length > 0) {
            if (lines[lines.length - 1] !== '') {
                lines.push('');
            }
        }
    };

    const isUnaryOp = (t, prev) => {
        if (!t || t.type !== TokenType.Operator || (t.text !== '-' && t.text !== '+')) return false;
        if (!prev) return true;
        if (prev.type === TokenType.OpenParen || prev.type === TokenType.OpenBracket || prev.type === TokenType.OpenBrace) return true;
        if (prev.type === TokenType.Comma || prev.type === TokenType.Colon || prev.type === TokenType.Semicolon) return true;
        if (prev.type === TokenType.Operator) return true;
        if (prev.type === TokenType.Preprocessor) return true;
        if (prev.type === TokenType.Word) {
            if (prev.text.startsWith('_')) {
                return false;
            }
            const lower = prev.text.toLowerCase();
            if (sqfNonOperandWords.has(lower)) {
                return true;
            }
            if (nativeCommandsMap.has(lower)) {
                const cmd = nativeCommandsMap.get(lower);
                if (cmd && (cmd.callType === 'binary' || cmd.callType === 'unary')) {
                    return true;
                }
                if (cmd && cmd.syntaxes && cmd.syntaxes.some(s => s.callType === 'binary' || s.callType === 'unary')) {
                    return true;
                }
            }
        }
        return false;
    };

    const generalScopeStack = []; // stores all scopes in order: { type: 'bracket'|'brace'|'paren', isSingleLine, isMacroCall, isSymbolMacro }

    const needSpace = (prev, curr) => {
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
            if (nativeCommandsMap.has(w)) {
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

    const style = braceStyle;

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
            i++;
            continue;
        }

        // Handle Multi-line OpenBrace {
        if (t.type === TokenType.OpenBrace) {
            generalScopeStack.push({ type: 'brace', isSingleLine: t.isSingleLine });
            if (!t.isSingleLine || !keepOneLineBlocks) {
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
            if (!t.isSingleLine || !keepOneLineBlocks) {
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
                        // else if continues on same line
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
                    if (afterElse && afterElse.type === TokenType.OpenBrace && (!afterElse.isSingleLine || !keepOneLineBlocks)) {
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
                    if (afterElse && afterElse.type === TokenType.OpenBrace && (!afterElse.isSingleLine || !keepOneLineBlocks)) {
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

function findSqfFiles(dir, fileList = []) {
    if (!fs.existsSync(dir)) return fileList;
    const entries = fs.readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            if (['node_modules', '.git', '.hemtt', '.hemttout'].includes(entry.name)) {
                continue;
            }
            findSqfFiles(fullPath, fileList);
        } else if (entry.isFile() && entry.name.endsWith('.sqf')) {
            fileList.push(fullPath);
        }
    }

    return fileList;
}

// Find all SQF files
const sqfFiles = findSqfFiles(targetDir);
console.log(`[BTC SQF] Found ${sqfFiles.length} .sqf files to process.`);

let updatedCount = 0;
let unchangedCount = 0;

for (let i = 0; i < sqfFiles.length; i++) {
    const filePath = sqfFiles[i];
    const relPath = path.relative(targetDir, filePath);

    try {
        const content = fs.readFileSync(filePath, 'utf-8');
        const formatted = formatSqf(content, {
            braceStyle,
            correctCasing: true,
            keepOneLineBlocks: true,
            tabSize,
            insertSpaces
        });

        if (formatted !== content) {
            if (!checkOnly) {
                fs.writeFileSync(filePath, formatted, 'utf-8');
            }
            updatedCount++;
            console.log(`[MODIFIED] ${relPath}`);
        } else {
            unchangedCount++;
        }
    } catch (err) {
        console.error(`[ERROR] Failed to process ${relPath}:`, err.message);
    }
}

console.log('----------------------------------------------------');
if (checkOnly) {
    console.log(`[BTC SQF] Check completed: ${updatedCount} files need formatting, ${unchangedCount} already formatted.`);
    if (updatedCount > 0) process.exit(1);
} else {
    console.log(`[BTC SQF] Formatting completed: ${updatedCount} files formatted, ${unchangedCount} already up to date.`);
}
