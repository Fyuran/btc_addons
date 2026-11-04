"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.SqfDefinitionProvider = void 0;
const vscode = __importStar(require("vscode"));
const cbaResolver_1 = require("./cbaResolver");
const syntaxClassifier_1 = require("./syntaxClassifier");
class SqfDefinitionProvider {
    indexer;
    nativeCommands;
    constructor(indexer, nativeCommands) {
        this.indexer = indexer;
        this.nativeCommands = nativeCommands;
    }
    provideDefinition(document, position, token) {
        // Do not parse or jump to definitions inside comments, comment blocks, or strings
        const classified = syntaxClassifier_1.SyntaxClassifier.getClassified(document);
        if (classified.isPositionInCommentOrString(position, document)) {
            return undefined;
        }
        const lineText = document.lineAt(position.line).text;
        const charIndex = position.character;
        // 1. Check CBA macros (FUNC, EFUNC, QFUNC, QEFUNC, etc.)
        const macro = cbaResolver_1.CbaResolver.findMacroAtPosition(lineText, charIndex, document.uri.fsPath);
        if (macro) {
            const funcInfo = this.indexer.findFunction(macro.component, macro.name, macro.fullName);
            if (funcInfo) {
                const targetUri = vscode.Uri.file(funcInfo.filePath);
                return new vscode.Location(targetUri, new vscode.Position(0, 0));
            }
        }
        // 2. Check raw word under cursor
        const wordRange = document.getWordRangeAtPosition(position, /[_a-zA-Z0-9]+/);
        if (wordRange) {
            const word = document.getText(wordRange);
            // Do not jump to user-defined functions if word is a native Arma 3 command (e.g. hideObject)
            if (this.nativeCommands && this.nativeCommands.hasCommand(word)) {
                return undefined;
            }
            const customFunc = this.indexer.findFunction(undefined, word, word);
            if (customFunc) {
                const targetUri = vscode.Uri.file(customFunc.filePath);
                return new vscode.Location(targetUri, new vscode.Position(0, 0));
            }
        }
        return undefined;
    }
}
exports.SqfDefinitionProvider = SqfDefinitionProvider;
//# sourceMappingURL=definitionProvider.js.map