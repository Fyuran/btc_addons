"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SyntaxClassifier = exports.CharType = void 0;
var CharType;
(function (CharType) {
    CharType[CharType["Code"] = 0] = "Code";
    CharType[CharType["LineComment"] = 1] = "LineComment";
    CharType[CharType["BlockComment"] = 2] = "BlockComment";
    CharType[CharType["String"] = 3] = "String";
})(CharType || (exports.CharType = CharType = {}));
var LexerState;
(function (LexerState) {
    LexerState[LexerState["Code"] = 0] = "Code";
    LexerState[LexerState["LineComment"] = 1] = "LineComment";
    LexerState[LexerState["BlockComment"] = 2] = "BlockComment";
    LexerState[LexerState["DoubleString"] = 3] = "DoubleString";
    LexerState[LexerState["SingleString"] = 4] = "SingleString";
})(LexerState || (LexerState = {}));
class SyntaxClassifier {
    static cache = new Map();
    static getClassified(document) {
        const key = document.uri.toString();
        const cached = this.cache.get(key);
        if (cached && cached.version === document.version) {
            return cached.classified;
        }
        const classified = this.classifyText(document.getText());
        this.cache.set(key, { version: document.version, classified });
        return classified;
    }
    static clearCache() {
        this.cache.clear();
    }
    static classifyText(text) {
        const len = text.length;
        const charTypes = new Uint8Array(len);
        let state = LexerState.Code;
        const maskedCommentsArr = new Array(len);
        const maskedCommentsAndStringsArr = new Array(len);
        const lineOffsets = [0];
        for (let i = 0; i < len; i++) {
            const ch = text[i];
            if (ch === '\n') {
                lineOffsets.push(i + 1);
            }
            const next = i + 1 < len ? text[i + 1] : '';
            if (state === LexerState.Code) {
                if (ch === '/' && next === '/') {
                    state = LexerState.LineComment;
                    charTypes[i] = CharType.LineComment;
                    maskedCommentsArr[i] = ' ';
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                else if (ch === '/' && next === '*') {
                    state = LexerState.BlockComment;
                    charTypes[i] = CharType.BlockComment;
                    maskedCommentsArr[i] = ' ';
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                else if (ch === '"') {
                    state = LexerState.DoubleString;
                    charTypes[i] = CharType.String;
                    maskedCommentsArr[i] = ch;
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                else if (ch === "'") {
                    state = LexerState.SingleString;
                    charTypes[i] = CharType.String;
                    maskedCommentsArr[i] = ch;
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                else {
                    charTypes[i] = CharType.Code;
                    maskedCommentsArr[i] = ch;
                    maskedCommentsAndStringsArr[i] = ch;
                }
            }
            else if (state === LexerState.LineComment) {
                if (ch === '\n') {
                    state = LexerState.Code;
                    charTypes[i] = CharType.Code;
                    maskedCommentsArr[i] = '\n';
                    maskedCommentsAndStringsArr[i] = '\n';
                }
                else {
                    charTypes[i] = CharType.LineComment;
                    maskedCommentsArr[i] = ' ';
                    maskedCommentsAndStringsArr[i] = ' ';
                }
            }
            else if (state === LexerState.BlockComment) {
                charTypes[i] = CharType.BlockComment;
                if (ch === '\n') {
                    maskedCommentsArr[i] = '\n';
                    maskedCommentsAndStringsArr[i] = '\n';
                }
                else {
                    maskedCommentsArr[i] = ' ';
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                if (ch === '*' && next === '/') {
                    i++;
                    if (i < len) {
                        charTypes[i] = CharType.BlockComment;
                        maskedCommentsArr[i] = ' ';
                        maskedCommentsAndStringsArr[i] = ' ';
                    }
                    state = LexerState.Code;
                }
            }
            else if (state === LexerState.DoubleString) {
                charTypes[i] = CharType.String;
                if (ch === '\n') {
                    maskedCommentsArr[i] = '\n';
                    maskedCommentsAndStringsArr[i] = '\n';
                }
                else {
                    maskedCommentsArr[i] = ch;
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                if (ch === '"') {
                    if (next === '"') {
                        // escaped "" in SQF
                        i++;
                        if (i < len) {
                            charTypes[i] = CharType.String;
                            maskedCommentsArr[i] = '"';
                            maskedCommentsAndStringsArr[i] = ' ';
                        }
                    }
                    else if (i > 0 && text[i - 1] === '\\') {
                        // backslash escaped \"
                    }
                    else {
                        state = LexerState.Code;
                    }
                }
            }
            else if (state === LexerState.SingleString) {
                charTypes[i] = CharType.String;
                if (ch === '\n') {
                    maskedCommentsArr[i] = '\n';
                    maskedCommentsAndStringsArr[i] = '\n';
                }
                else {
                    maskedCommentsArr[i] = ch;
                    maskedCommentsAndStringsArr[i] = ' ';
                }
                if (ch === "'") {
                    if (next === "'") {
                        // escaped '' in SQF
                        i++;
                        if (i < len) {
                            charTypes[i] = CharType.String;
                            maskedCommentsArr[i] = "'";
                            maskedCommentsAndStringsArr[i] = ' ';
                        }
                    }
                    else if (i > 0 && text[i - 1] === '\\') {
                        // backslash escaped \'
                    }
                    else {
                        state = LexerState.Code;
                    }
                }
            }
        }
        const maskedComments = maskedCommentsArr.join('');
        const maskedCommentsAndStrings = maskedCommentsAndStringsArr.join('');
        const lineMaskedCommentsAndStrings = maskedCommentsAndStrings.split('\n');
        const lineMaskedCommentsOnly = maskedComments.split('\n');
        return {
            charTypes,
            maskedComments,
            maskedCommentsAndStrings,
            lineOffsets,
            lineMaskedCommentsAndStrings,
            isInsideCommentOrString: (offset) => {
                if (offset < 0 || offset >= len)
                    return false;
                return charTypes[offset] !== CharType.Code;
            },
            isInsideComment: (offset) => {
                if (offset < 0 || offset >= len)
                    return false;
                const t = charTypes[offset];
                return t === CharType.LineComment || t === CharType.BlockComment;
            },
            isInsideString: (offset) => {
                if (offset < 0 || offset >= len)
                    return false;
                return charTypes[offset] === CharType.String;
            },
            isPositionInCommentOrString: (position, document) => {
                let offset;
                if (document) {
                    offset = document.offsetAt(position);
                }
                else {
                    const lineStart = lineOffsets[position.line] ?? 0;
                    offset = lineStart + position.character;
                }
                if (offset < 0 || offset >= len)
                    return false;
                return charTypes[offset] !== CharType.Code;
            },
            getLineMasked: (lineIdx) => {
                return lineMaskedCommentsAndStrings[lineIdx] ?? '';
            },
            getLineMaskedCommentsOnly: (lineIdx) => {
                return lineMaskedCommentsOnly[lineIdx] ?? '';
            },
            getLineFromOffset: (offset) => {
                let low = 0;
                let high = lineOffsets.length - 1;
                while (low <= high) {
                    const mid = (low + high) >> 1;
                    if (lineOffsets[mid] <= offset) {
                        low = mid + 1;
                    }
                    else {
                        high = mid - 1;
                    }
                }
                return Math.max(0, high);
            },
            getBraceDepth: (offset) => {
                const target = Math.min(offset, maskedCommentsAndStrings.length);
                let depth = 0;
                for (let j = 0; j < target; j++) {
                    const c = maskedCommentsAndStrings[j];
                    if (c === '{')
                        depth++;
                    else if (c === '}')
                        depth = Math.max(0, depth - 1);
                }
                return depth;
            }
        };
    }
    static maskComments(text) {
        return this.classifyText(text).maskedComments;
    }
    static maskCommentsAndStrings(text) {
        return this.classifyText(text).maskedCommentsAndStrings;
    }
}
exports.SyntaxClassifier = SyntaxClassifier;
//# sourceMappingURL=syntaxClassifier.js.map