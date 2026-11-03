import * as vscode from 'vscode';
import { WorkspaceIndexer } from './workspaceIndexer';
import { CbaResolver } from './cbaResolver';
import { SyntaxClassifier } from './syntaxClassifier';

export class SqfDefinitionProvider implements vscode.DefinitionProvider {
    constructor(private indexer: WorkspaceIndexer) {}

    public provideDefinition(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.Definition> {
        // Do not parse or jump to definitions inside comments, comment blocks, or strings
        const classified = SyntaxClassifier.getClassified(document);
        if (classified.isPositionInCommentOrString(position, document)) {
            return undefined;
        }

        const lineText = document.lineAt(position.line).text;
        const charIndex = position.character;

        // 1. Check CBA macros (FUNC, EFUNC, QFUNC, QEFUNC, etc.)
        const macro = CbaResolver.findMacroAtPosition(lineText, charIndex, document.uri.fsPath);
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
            const customFunc = this.indexer.findFunction(undefined, word, word);
            if (customFunc) {
                const targetUri = vscode.Uri.file(customFunc.filePath);
                return new vscode.Location(targetUri, new vscode.Position(0, 0));
            }
        }

        return undefined;
    }
}

