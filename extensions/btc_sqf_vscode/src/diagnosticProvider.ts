import * as vscode from 'vscode';
import { NativeCommandsManager } from './nativeCommands';
import { VariableTypeInferrer } from './variableInferrer';
import { InferredVariable } from './types';
import { WorkspaceIndexer } from './workspaceIndexer';
import { SyntaxClassifier } from './syntaxClassifier';

export class SqfDiagnosticProvider {
    private diagnosticCollection: vscode.DiagnosticCollection;

    private static IGNORED_COMMANDS: Set<string> = new Set([
        'private', 'params', 'if', 'then', 'else', 'while', 'do',
        'waituntil', 'exitwith', 'return', 'assert', 'case', 'default',
        'try', 'catch', 'throw', 'for', 'from', 'to', 'step', 'with', 'switch'
    ]);

    constructor(
        private nativeCommands: NativeCommandsManager,
        private indexer?: WorkspaceIndexer
    ) {
        this.diagnosticCollection = vscode.languages.createDiagnosticCollection('btcSqf');
    }

    public subscribe(context: vscode.ExtensionContext) {
        context.subscriptions.push(this.diagnosticCollection);

        context.subscriptions.push(
            vscode.workspace.onDidOpenTextDocument(doc => this.checkDocument(doc)),
            vscode.workspace.onDidChangeTextDocument(e => this.checkDocument(e.document)),
            vscode.workspace.onDidCloseTextDocument(doc => this.diagnosticCollection.delete(doc.uri))
        );

        // Check open documents
        vscode.workspace.textDocuments.forEach(doc => this.checkDocument(doc));
    }

    public checkDocument(document: vscode.TextDocument) {
        if (document.languageId !== 'sqf' && !document.fileName.endsWith('.sqf')) {
            return;
        }

        const config = vscode.workspace.getConfiguration('btcSqf');
        if (!config.get<boolean>('enableTypeChecking', true)) {
            this.diagnosticCollection.delete(document.uri);
            return;
        }

        const diagnostics: vscode.Diagnostic[] = [];
        const variables = new Map<string, InferredVariable>();
        const classified = SyntaxClassifier.getClassified(document);
        VariableTypeInferrer.parseAllParams(classified.maskedComments, variables, classified, { topLevelOnly: true });
        const warnGetVarWithoutDefault = config.get<boolean>('warnGetVariableWithoutDefault', true);

        const scopeStack: Array<{ depth: number; saved: Map<string, InferredVariable | undefined> }> = [];
        let currentDepth = 0;

        for (let lineIdx = 0; lineIdx < document.lineCount; lineIdx++) {
            const cleanLine = classified.getLineMasked(lineIdx);
            const cleanLineCommentsOnly = classified.getLineMaskedCommentsOnly(lineIdx);
            const trimmed = cleanLine.trim();
            if (!trimmed || trimmed.startsWith('#')) {
                continue;
            }

            const narrowings = VariableTypeInferrer.detectTypeNarrowing(cleanLineCommentsOnly);
            const maskedCodeLine = classified.lineMaskedCommentsAndStrings[lineIdx] ?? '';
            let lastProcessedCol = 0;

            const processScopeCharsUpTo = (endCol: number) => {
                for (let c = lastProcessedCol; c < endCol; c++) {
                    const ch = maskedCodeLine[c];
                    if (ch === '{') {
                        currentDepth++;
                        const saved = new Map<string, InferredVariable | undefined>();
                        if (narrowings.length > 0) {
                            for (const n of narrowings) {
                                const existing = variables.get(n.varName.toLowerCase());
                                saved.set(n.varName.toLowerCase(), existing ? { ...existing } : undefined);
                                variables.set(n.varName.toLowerCase(), {
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
                                    variables.set(k, v);
                                } else {
                                    variables.delete(k);
                                }
                            }
                        }
                        currentDepth = Math.max(0, currentDepth - 1);
                    }
                }
                lastProcessedCol = endCol;
            };

            // Parse local params inside blocks
            if (currentDepth > 0 && /\bparams\s*\[/i.test(cleanLineCommentsOnly)) {
                const localParamsMap = new Map<string, InferredVariable>();
                VariableTypeInferrer.parseAllParams(cleanLineCommentsOnly, localParamsMap, undefined);
                for (const [k, v] of localParamsMap) {
                    if (scopeStack.length > 0) {
                        const top = scopeStack[scopeStack.length - 1];
                        if (!top.saved.has(k)) {
                            const existing = variables.get(k);
                            top.saved.set(k, existing ? { ...existing } : undefined);
                        }
                    }
                    variables.set(k, { ...v, line: lineIdx, depth: currentDepth });
                }
            }

            // Track loop variable for "_i" from ...
            const forMatch = cleanLineCommentsOnly.match(/\bfor\s+["'](_[a-zA-Z0-9_]+)["']\s+from\b/i);
            if (forMatch) {
                const varName = forMatch[1];
                if (currentDepth > 0 && scopeStack.length > 0) {
                    const top = scopeStack[scopeStack.length - 1];
                    if (!top.saved.has(varName.toLowerCase())) {
                        const existing = variables.get(varName.toLowerCase());
                        top.saved.set(varName.toLowerCase(), existing ? { ...existing } : undefined);
                    }
                }
                variables.set(varName.toLowerCase(), {
                    name: varName,
                    type: 'Number',
                    line: lineIdx,
                    declarationText: document.lineAt(lineIdx).text.trim(),
                    depth: currentDepth
                });
            }

            // Collect assignments to apply after validating expressions on this line
            const pendingUpdates: Array<{ varName: string; inferredType: string; isParam?: boolean }> = [];
            const assignments = VariableTypeInferrer.extractAssignmentsAtLine(document, lineIdx, classified);
            for (const assign of assignments) {
                const inferredType = VariableTypeInferrer.inferExpressionType(
                    assign.rawExpr,
                    variables,
                    this.nativeCommands,
                    this.indexer,
                    document.uri.fsPath
                );
                const existing = variables.get(assign.varName.toLowerCase());
                if (inferredType !== 'Any' || !existing) {
                    pendingUpdates.push({
                        varName: assign.varName,
                        inferredType,
                        isParam: existing?.isParameter
                    });
                }
            }

            const tokenRegex = /\b([a-zA-Z0-9_]+)\b/g;
            let match: RegExpExecArray | null;

            while ((match = tokenRegex.exec(cleanLine)) !== null) {
                processScopeCharsUpTo(match.index);
                const token = match[1];

                // Check for getVariable without default fallback value
                if (token.toLowerCase() === 'getvariable' && warnGetVarWithoutDefault) {
                    const after = cleanLineCommentsOnly.slice(match.index + token.length).trim();
                    const argMatch = after.match(/^("[^"]*"|'[^']*'|\[[^\]]*\])/);
                    let hasDefault = false;
                    if (argMatch) {
                        const arg = argMatch[1];
                        if (arg.startsWith('[') && arg.includes(',')) {
                            hasDefault = true;
                        }
                    }
                    if (!hasDefault) {
                        const range = new vscode.Range(lineIdx, match.index, lineIdx, match.index + token.length);
                        diagnostics.push(new vscode.Diagnostic(
                            range,
                            `Best Practice: 'getVariable' without a default fallback returns 'nil' if unset, which can cause runtime errors. Consider using: getVariable [name, defaultValue].`,
                            vscode.DiagnosticSeverity.Warning
                        ));
                    }
                }

                if (SqfDiagnosticProvider.IGNORED_COMMANDS.has(token.toLowerCase())) {
                    continue;
                }

                const cmd = this.nativeCommands.getCommand(token);
                if (!cmd || !cmd.syntaxes || cmd.syntaxes.length === 0) {
                    continue;
                }

                const leftExpr = VariableTypeInferrer.extractLeftOperand(cleanLineCommentsOnly, match.index);

                // 1. Binary invocation: command has a valid left operand
                if (leftExpr) {
                    const binarySyntaxes = cmd.syntaxes.filter(s => s.callType === 'binary');
                    if (binarySyntaxes.length === 0) {
                        continue;
                    }

                    const inferredLeft = VariableTypeInferrer.inferExpressionType(leftExpr, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                    const rightExpr = VariableTypeInferrer.extractRightOperand(cleanLineCommentsOnly, match.index + token.length);
                    const inferredRight = rightExpr ? VariableTypeInferrer.inferExpressionType(rightExpr, variables, this.nativeCommands, this.indexer, document.uri.fsPath) : 'Any';

                    // Only validate if concrete types are known for both operands
                    if (inferredLeft === 'Any' || inferredRight === 'Any') {
                        continue;
                    }

                    // Check if AT LEAST ONE binary overload matches
                    let specificError: string | undefined;
                    const matched = binarySyntaxes.some(syn => {
                        const leftCheck = syn.leftParam
                            ? VariableTypeInferrer.checkArgument(leftExpr, inferredLeft, syn.leftParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath)
                            : { isValid: true, reason: undefined };
                        const rightCheck = syn.rightParam
                            ? VariableTypeInferrer.checkArgument(rightExpr, inferredRight, syn.rightParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath)
                            : { isValid: true, reason: undefined };
                        if (!leftCheck.isValid && leftCheck.reason) {
                            specificError = leftCheck.reason;
                        } else if (!rightCheck.isValid && rightCheck.reason) {
                            specificError = rightCheck.reason;
                        }
                        return leftCheck.isValid && rightCheck.isValid;
                    });

                    if (!matched) {
                        const range = new vscode.Range(lineIdx, match.index, lineIdx, match.index + token.length);
                        const expectedSignatures = binarySyntaxes.map(s => s.typedSignature).join(' OR ');
                        const msg = specificError
                            ? `Type Warning: ${specificError}. Expected: ${expectedSignatures}`
                            : `Type Warning: None of the signatures for '${cmd.name}' match argument types '(${inferredLeft}, ${inferredRight})'. Expected: ${expectedSignatures}`;
                        diagnostics.push(new vscode.Diagnostic(
                            range,
                            msg,
                            vscode.DiagnosticSeverity.Warning
                        ));
                    }
                }
                // 2. Unary invocation: no left operand
                else {
                    const unarySyntaxes = cmd.syntaxes.filter(s => s.callType === 'unary');
                    if (unarySyntaxes.length === 0) {
                        continue;
                    }

                    const rightExpr = VariableTypeInferrer.extractRightOperand(cleanLineCommentsOnly, match.index + token.length);
                    if (!rightExpr) {
                        continue;
                    }

                    const inferredRight = VariableTypeInferrer.inferExpressionType(rightExpr, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                    if (inferredRight === 'Any') {
                        continue;
                    }

                    // Check if AT LEAST ONE unary overload matches
                    let specificError: string | undefined;
                    const matched = unarySyntaxes.some(syn => {
                        if (!syn.rightParam) return true;
                        const check = VariableTypeInferrer.checkArgument(rightExpr, inferredRight, syn.rightParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                        if (!check.isValid && check.reason) {
                            specificError = check.reason;
                        }
                        return check.isValid;
                    });

                    if (!matched) {
                        const range = new vscode.Range(lineIdx, match.index, lineIdx, match.index + token.length);
                        const expectedSignatures = unarySyntaxes.map(s => s.typedSignature).join(' OR ');
                        const msg = specificError
                            ? `Type Warning: ${specificError}. Expected: ${expectedSignatures}`
                            : `Type Warning: No overload of '${cmd.name}' matches argument type '(${inferredRight})'. Expected: ${expectedSignatures}`;
                        diagnostics.push(new vscode.Diagnostic(
                            range,
                            msg,
                            vscode.DiagnosticSeverity.Warning
                        ));
                    }
                }
            }

            processScopeCharsUpTo(maskedCodeLine.length);

            // Apply pending updates after this line has been validated
            for (const update of pendingUpdates) {
                if (currentDepth > 0 && scopeStack.length > 0) {
                    const top = scopeStack[scopeStack.length - 1];
                    if (!top.saved.has(update.varName.toLowerCase())) {
                        const existing = variables.get(update.varName.toLowerCase());
                        top.saved.set(update.varName.toLowerCase(), existing ? { ...existing } : undefined);
                    }
                }
                variables.set(update.varName.toLowerCase(), {
                    name: update.varName,
                    type: update.inferredType,
                    line: lineIdx,
                    declarationText: document.lineAt(lineIdx).text.trim(),
                    isParameter: update.isParam,
                    depth: currentDepth
                });
            }
        }

        this.diagnosticCollection.set(document.uri, diagnostics);
    }
}
