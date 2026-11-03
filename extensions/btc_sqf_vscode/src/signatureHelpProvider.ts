import * as vscode from 'vscode';
import { WorkspaceIndexer } from './workspaceIndexer';
import { CbaResolver } from './cbaResolver';
import { SyntaxClassifier } from './syntaxClassifier';

export class SqfSignatureHelpProvider implements vscode.SignatureHelpProvider {
    constructor(private indexer: WorkspaceIndexer) {}

    public provideSignatureHelp(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken,
        context: vscode.SignatureHelpContext
    ): vscode.ProviderResult<vscode.SignatureHelp> {
        // Forbid signature hints when typing a comma
        if (context.triggerCharacter === ',') {
            return undefined;
        }

        // Do not provide signature help inside comments, comment blocks, or strings
        const classified = SyntaxClassifier.getClassified(document);
        if (classified.isPositionInCommentOrString(position, document)) {
            return undefined;
        }

        const lineText = document.lineAt(position.line).text;
        const charPos = position.character;

        const callInfo = this.findEnclosingCall(lineText, charPos);
        if (!callInfo) {
            return undefined;
        }

        // Resolve macro / function
        let macro = callInfo.targetCharPos !== -1
            ? CbaResolver.findMacroAtPosition(lineText, callInfo.targetCharPos, document.uri.fsPath)
            : undefined;

        if (!macro) {
            // Try matching macro text directly
            const funcMatch = callInfo.targetText.match(/\b(Q?FUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*\)/i);
            const efuncMatch = callInfo.targetText.match(/\b(Q?EFUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/i);
            const ctx = CbaResolver.resolveContext(document.uri.fsPath);

            if (efuncMatch) {
                macro = {
                    type: efuncMatch[1].toUpperCase() as any,
                    prefix: ctx.prefix,
                    component: efuncMatch[2],
                    name: efuncMatch[3],
                    fullName: `${ctx.prefix}_${efuncMatch[2]}_fnc_${efuncMatch[3]}`,
                    range: { startChar: 0, endChar: 0 }
                };
            } else if (funcMatch) {
                macro = {
                    type: funcMatch[1].toUpperCase() as any,
                    prefix: ctx.prefix,
                    component: ctx.component,
                    name: funcMatch[2],
                    fullName: `${ctx.prefix}_${ctx.component}_fnc_${funcMatch[2]}`,
                    range: { startChar: 0, endChar: 0 }
                };
            }
        }

        const funcInfo = macro
            ? this.indexer.findFunction(macro.component, macro.name, macro.fullName)
            : this.indexer.findFunction(undefined, undefined, callInfo.targetText);

        if (!funcInfo || !funcInfo.parameters || funcInfo.parameters.length === 0) {
            return undefined;
        }

        const sigHelp = new vscode.SignatureHelp();
        const paramLabels = funcInfo.parameters.map(p => `${p.name}${p.optional ? '?' : ''}: ${p.type}`);
        const callMacro = macro?.type === 'EFUNC'
            ? `EFUNC(${funcInfo.component}, ${funcInfo.shortName})`
            : macro?.type === 'RAW_FUNC'
            ? funcInfo.fullName
            : `FUNC(${funcInfo.shortName})`;

        const label = `[${paramLabels.join(', ')}] call ${callMacro}`;

        const sigInfo = new vscode.SignatureInformation(label, funcInfo.description);
        sigInfo.parameters = funcInfo.parameters.map(p => {
            const desc = p.description ? ` - ${p.description}` : '';
            const def = p.defaultValue ? ` (default: ${p.defaultValue})` : '';
            return new vscode.ParameterInformation(
                `${p.name}: ${p.type}`,
                `${p.name} (${p.type})${def}${desc}`
            );
        });

        sigHelp.signatures = [sigInfo];
        sigHelp.activeSignature = 0;
        sigHelp.activeParameter = Math.min(callInfo.activeParam, funcInfo.parameters.length - 1);

        return sigHelp;
    }

    /**
     * Find enclosing argument bracket and its target function invocation.
     */
    private findEnclosingCall(
        lineText: string,
        charPos: number
    ): { targetText: string; targetCharPos: number; activeParam: number } | undefined {
        // 1. Scan backward from charPos to find opening bracket '['
        let bracketDepth = 0;
        let braceDepth = 0;
        let inString = false;
        let quoteChar = '';
        let openBracketPos = -1;

        for (let i = charPos - 1; i >= 0; i--) {
            const c = lineText[i];
            if (inString) {
                if (c === quoteChar) inString = false;
                continue;
            }
            if (c === '"' || c === "'") {
                inString = true;
                quoteChar = c;
            } else if (c === '}') {
                braceDepth++;
            } else if (c === '{') {
                if (braceDepth > 0) braceDepth--;
            } else if (braceDepth === 0) {
                if (c === ']') {
                    bracketDepth++;
                } else if (c === '[') {
                    if (bracketDepth > 0) {
                        bracketDepth--;
                    } else {
                        openBracketPos = i;
                        break;
                    }
                }
            }
        }

        // If not inside an arguments bracket, check if cursor is on/after 'call'
        if (openBracketPos === -1) {
            const callRegex = /\bcall\s+(Q?(?:E?FUNC)\s*\(\s*[^)]+\)|[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+|[a-zA-Z0-9_]+)/gi;
            let m: RegExpExecArray | null;
            while ((m = callRegex.exec(lineText)) !== null) {
                const start = m.index;
                const end = start + m[0].length;
                if (charPos >= start && charPos <= end + 1) {
                    const targetText = m[1];
                    const targetCharPos = start + m[0].indexOf(targetText);
                    return { targetText, targetCharPos, activeParam: 0 };
                }
            }
            return undefined;
        }

        // 2. Scan forward from openBracketPos to find matching closing ']'
        let closeBracketPos = -1;
        let depth = 0;
        let brDepth = 0;
        for (let i = openBracketPos; i < lineText.length; i++) {
            const c = lineText[i];
            if (c === '{') brDepth++;
            else if (c === '}') {
                if (brDepth > 0) brDepth--;
            } else if (brDepth === 0) {
                if (c === '[') depth++;
                else if (c === ']') {
                    depth--;
                    if (depth === 0) {
                        closeBracketPos = i;
                        break;
                    }
                }
            }
        }

        let targetText: string | undefined;
        let targetCharPos = -1;

        if (closeBracketPos !== -1) {
            const afterBracket = lineText.slice(closeBracketPos + 1);
            const callMatch = afterBracket.match(/^\s*call\s+(Q?(?:E?FUNC)\s*\(\s*[^)]+\)|[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+|[a-zA-Z0-9_]+)/i);
            if (callMatch) {
                targetText = callMatch[1];
                targetCharPos = closeBracketPos + 1 + callMatch.index! + callMatch[0].indexOf(targetText);
            }
        }

        if (!targetText) {
            const fallbackMatch = lineText.match(/\bcall\s+(Q?(?:E?FUNC)\s*\(\s*[^)]+\)|[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+|[a-zA-Z0-9_]+)/i);
            if (fallbackMatch) {
                targetText = fallbackMatch[1];
                targetCharPos = fallbackMatch.index! + fallbackMatch[0].indexOf(targetText);
            }
        }

        if (!targetText) {
            return undefined;
        }

        // 3. Count active parameter index between openBracketPos and charPos
        let activeParam = 0;
        let bDepth = 0;
        let cBrDepth = 0;
        let pDepth = 0;
        let inStr = false;
        let strChar = '';

        for (let i = openBracketPos + 1; i < charPos; i++) {
            const c = lineText[i];
            if (inStr) {
                if (c === strChar) inStr = false;
                continue;
            }
            if (c === '"' || c === "'") {
                inStr = true;
                strChar = c;
            } else if (c === '[') {
                bDepth++;
            } else if (c === ']') {
                if (bDepth > 0) bDepth--;
            } else if (c === '{') {
                cBrDepth++;
            } else if (c === '}') {
                if (cBrDepth > 0) cBrDepth--;
            } else if (c === '(') {
                pDepth++;
            } else if (c === ')') {
                if (pDepth > 0) pDepth--;
            } else if (c === ',' && bDepth === 0 && cBrDepth === 0 && pDepth === 0) {
                activeParam++;
            }
        }

        return { targetText, targetCharPos, activeParam };
    }
}
