import * as vscode from 'vscode';
import * as path from 'path';
import { NativeCommandsManager } from './nativeCommands';
import { WorkspaceIndexer } from './workspaceIndexer';
import { SqfHoverProvider } from './hoverProvider';
import { SqfDefinitionProvider } from './definitionProvider';
import { SqfSignatureHelpProvider } from './signatureHelpProvider';
import { SqfCompletionItemProvider } from './completionItemProvider';
import { SqfDiagnosticProvider } from './diagnosticProvider';
import { SqfSemanticTokensProvider, semanticLegend } from './semanticTokensProvider';
import { SqfRenameProvider } from './renameProvider';
import { CbaResolver } from './cbaResolver';
import { HeaderUpdater } from './headerUpdater';
import { XehPrepBuilder } from './xehPrepBuilder';
import { BtcSqfToolsTreeDataProvider } from './sidebarProvider';
import { VariableTypeInferrer } from './variableInferrer';

export async function activate(context: vscode.ExtensionContext) {
    console.log('[BTC SQF] Activating BTC SQF & CBA IntelliSense extension...');

    // Load user configuration
    const config = vscode.workspace.getConfiguration('btcSqf');
    const defaultPrefix = config.get<string>('defaultPrefix', 'btc_toolchain');
    CbaResolver.setDefaultPrefix(defaultPrefix);

    // Initialize native commands database
    const nativeCommands = new NativeCommandsManager(context.extensionPath);

    // Initialize workspace indexer
    const indexer = new WorkspaceIndexer();
    await indexer.indexWorkspace();

    console.log(`[BTC SQF] Indexed ${indexer.getAllFunctions().length} functions across workspace.`);
    VariableTypeInferrer.setIndexer(indexer);

    // Supported language selectors
    const documentSelectors: vscode.DocumentSelector = [
        { language: 'sqf', scheme: 'file' },
        { language: 'arma-cfg', scheme: 'file' },
        { pattern: '**/*.sqf', scheme: 'file' },
        { pattern: '**/*.hpp', scheme: 'file' }
    ];

    // Register Hover Provider (Native commands, CBA functions, variables, operands)
    const hoverProvider = new SqfHoverProvider(nativeCommands, indexer);
    context.subscriptions.push(
        vscode.languages.registerHoverProvider(documentSelectors, hoverProvider)
    );

    // Register Definition Provider (F12 / Ctrl+Click)
    const defProvider = new SqfDefinitionProvider(indexer, nativeCommands);
    context.subscriptions.push(
        vscode.languages.registerDefinitionProvider(documentSelectors, defProvider)
    );

    // Register Rename Provider (F2 / Right-click -> Rename Symbol for local variables, globals, and functions)
    const renameProvider = new SqfRenameProvider(indexer, nativeCommands);
    context.subscriptions.push(
        vscode.languages.registerRenameProvider(documentSelectors, renameProvider)
    );

    // Register Signature Help Provider
    const sigHelpProvider = new SqfSignatureHelpProvider(indexer);
    context.subscriptions.push(
        vscode.languages.registerSignatureHelpProvider(documentSelectors, sigHelpProvider, '(')
    );

    // Register Completion Item Provider (IntelliSense auto-complete for CBA macros, functions, native commands, variables)
    const completionProvider = new SqfCompletionItemProvider(indexer, nativeCommands);
    context.subscriptions.push(
        vscode.languages.registerCompletionItemProvider(
            documentSelectors,
            completionProvider,
            '(', '_', ' ', '[', '"', "'"
        )
    );

    // Register Diagnostic Provider (Real-time type checking and operand validation)
    const diagnosticProvider = new SqfDiagnosticProvider(nativeCommands, indexer);
    diagnosticProvider.subscribe(context);

    // Register Semantic Tokens Provider (C++ style coloring for local/global vars, macros, defines)
    const semanticTokensProvider = new SqfSemanticTokensProvider();
    context.subscriptions.push(
        vscode.languages.registerDocumentSemanticTokensProvider(
            documentSelectors,
            semanticTokensProvider,
            semanticLegend
        )
    );

    // Watch for saved files to keep index fresh
    context.subscriptions.push(
        vscode.workspace.onDidSaveTextDocument(doc => {
            const fsPath = doc.uri.fsPath;
            if (fsPath.endsWith('.sqf')) {
                indexer.indexFile(fsPath);
                diagnosticProvider.checkDocument(doc);
            } else if (fsPath.endsWith('XEH_PREP.hpp')) {
                indexer.indexXehPrep(fsPath);
            }
        })
    );

    // Watch for config changes
    context.subscriptions.push(
        vscode.workspace.onDidChangeConfiguration(e => {
            if (e.affectsConfiguration('btcSqf.defaultPrefix')) {
                const newPrefix = vscode.workspace.getConfiguration('btcSqf').get<string>('defaultPrefix', 'btc_toolchain');
                CbaResolver.setDefaultPrefix(newPrefix);
            }
            if (e.affectsConfiguration('btcSqf.enableTypeChecking')) {
                vscode.workspace.textDocuments.forEach(doc => diagnosticProvider.checkDocument(doc));
            }
        })
    );

    // Register Sidebar TreeDataProvider for BTC SQF Tools
    const sidebarProvider = new BtcSqfToolsTreeDataProvider();
    context.subscriptions.push(
        vscode.window.registerTreeDataProvider('btcSqfToolsView', sidebarProvider)
    );

    // Command: Update Comment Header (Active File)
    context.subscriptions.push(
        vscode.commands.registerCommand('btc-sqf.updateCurrentHeader', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showWarningMessage('BTC SQF: No active editor. Please open an SQF file.');
                return;
            }

            const doc = editor.document;
            if (!doc.uri.fsPath.endsWith('.sqf')) {
                vscode.window.showWarningMessage('BTC SQF: Active file is not an SQF file.');
                return;
            }

            const result = HeaderUpdater.updateHeader(doc.uri.fsPath, doc.getText(), indexer, nativeCommands);
            if (result.changed) {
                const fullRange = new vscode.Range(
                    doc.positionAt(0),
                    doc.positionAt(doc.getText().length)
                );
                await editor.edit(editBuilder => {
                    editBuilder.replace(fullRange, result.newContent);
                });
                vscode.window.showInformationMessage(`BTC SQF: Updated header for ${result.newFunctionName} (Returns: ${result.newReturns})`);
            } else {
                vscode.window.showInformationMessage(`BTC SQF: Header is already up to date for ${result.newFunctionName}.`);
            }
        })
    );

    // Command: Update All Headers (Workspace)
    context.subscriptions.push(
        vscode.commands.registerCommand('btc-sqf.updateAllHeaders', async () => {
            const sqfFiles = await vscode.workspace.findFiles('**/fnc_*.sqf', '**/node_modules/**');
            if (sqfFiles.length === 0) {
                vscode.window.showInformationMessage('BTC SQF: No fnc_*.sqf files found in workspace.');
                return;
            }

            await vscode.window.withProgress(
                {
                    location: vscode.ProgressLocation.Notification,
                    title: 'BTC SQF: Updating comment headers across workspace...',
                    cancellable: true
                },
                async (progress, token) => {
                    let updatedCount = 0;
                    let unchangedCount = 0;
                    const total = sqfFiles.length;

                    for (let i = 0; i < total; i++) {
                        if (token.isCancellationRequested) {
                            break;
                        }

                        const uri = sqfFiles[i];
                        const filePath = uri.fsPath;
                        const fileName = vscode.workspace.asRelativePath(uri);

                        progress.report({
                            message: `[${i + 1}/${total}] ${fileName}`,
                            increment: (1 / total) * 100
                        });

                        try {
                            const rawBytes = await vscode.workspace.fs.readFile(uri);
                            const content = new TextDecoder('utf-8').decode(rawBytes);
                            const result = HeaderUpdater.updateHeader(filePath, content, indexer, nativeCommands);

                            if (result.changed) {
                                await vscode.workspace.fs.writeFile(uri, new TextEncoder().encode(result.newContent));
                                updatedCount++;
                            } else {
                                unchangedCount++;
                            }
                        } catch (err) {
                            console.error(`[BTC SQF] Failed to update header for ${filePath}:`, err);
                        }
                    }

                    // Refresh workspace index and diagnostics
                    await indexer.indexWorkspace();
                    vscode.window.showInformationMessage(
                        `BTC SQF: Completed updating headers. ${updatedCount} files updated, ${unchangedCount} already up to date.`
                    );
                }
            );
        })
    );

    // Command: Generate / Update XEH_PREP.hpp (Current Component)
    context.subscriptions.push(
        vscode.commands.registerCommand('btc-sqf.generateCurrentXehPrep', async () => {
            let targetPath: string | undefined;
            const editor = vscode.window.activeTextEditor;

            if (editor) {
                targetPath = editor.document.uri.fsPath;
            }

            if (!targetPath) {
                // If no active editor, search for all addons with functions/
                const prepUris = await vscode.workspace.findFiles('**/functions', '**/node_modules/**');
                if (prepUris.length === 0) {
                    vscode.window.showWarningMessage('BTC SQF: No addon functions directory found in workspace.');
                    return;
                }

                const addonChoices = prepUris.map(uri => {
                    const addonDir = path.dirname(uri.fsPath);
                    return {
                        label: path.basename(addonDir),
                        description: vscode.workspace.asRelativePath(addonDir),
                        addonDir
                    };
                });

                const picked = await vscode.window.showQuickPick(addonChoices, {
                    placeHolder: 'Select component to generate XEH_PREP.hpp for:'
                });
                if (!picked) return;
                targetPath = picked.addonDir;
            }

            if (!targetPath) {
                return;
            }

            const result = XehPrepBuilder.buildXehPrep(targetPath);
            if (!result) {
                vscode.window.showWarningMessage('BTC SQF: Could not find addon functions directory for current file.');
                return;
            }

            // If active editor is currently viewing this XEH_PREP.hpp, apply directly to editor
            if (editor && editor.document.uri.fsPath.toLowerCase() === result.targetFilePath.toLowerCase()) {
                const doc = editor.document;
                const fullRange = new vscode.Range(
                    doc.positionAt(0),
                    doc.positionAt(doc.getText().length)
                );
                await editor.edit(editBuilder => {
                    editBuilder.replace(fullRange, result.newContent);
                });
            } else {
                // Write file to disk
                const targetUri = vscode.Uri.file(result.targetFilePath);
                await vscode.workspace.fs.writeFile(targetUri, new TextEncoder().encode(result.newContent));
            }

            indexer.indexXehPrep(result.targetFilePath);
            vscode.window.showInformationMessage(
                `BTC SQF: Constructed XEH_PREP.hpp for ${result.addonName} (${result.functionsFound} functions prepped).`
            );
        })
    );

    // Command: Generate All XEH_PREP.hpp (Workspace)
    context.subscriptions.push(
        vscode.commands.registerCommand('btc-sqf.generateAllXehPrep', async () => {
            const funcFolders = await vscode.workspace.findFiles('**/functions', '**/node_modules/**');
            if (funcFolders.length === 0) {
                vscode.window.showInformationMessage('BTC SQF: No functions folders found in workspace.');
                return;
            }

            await vscode.window.withProgress(
                {
                    location: vscode.ProgressLocation.Notification,
                    title: 'BTC SQF: Generating XEH_PREP.hpp across all workspace addons...',
                    cancellable: true
                },
                async (progress, token) => {
                    let updatedCount = 0;
                    let unchangedCount = 0;
                    let totalFunctions = 0;
                    const total = funcFolders.length;

                    for (let i = 0; i < total; i++) {
                        if (token.isCancellationRequested) {
                            break;
                        }

                        const folderUri = funcFolders[i];
                        const addonDir = path.dirname(folderUri.fsPath);
                        const addonName = path.basename(addonDir);

                        progress.report({
                            message: `[${i + 1}/${total}] ${addonName}`,
                            increment: (1 / total) * 100
                        });

                        try {
                            const result = XehPrepBuilder.buildXehPrep(addonDir);
                            if (result) {
                                totalFunctions += result.functionsFound;
                                if (result.changed) {
                                    const targetUri = vscode.Uri.file(result.targetFilePath);
                                    await vscode.workspace.fs.writeFile(
                                        targetUri,
                                        new TextEncoder().encode(result.newContent)
                                    );
                                    updatedCount++;
                                } else {
                                    unchangedCount++;
                                }
                                indexer.indexXehPrep(result.targetFilePath);
                            }
                        } catch (err) {
                            console.error(`[BTC SQF] Failed to generate XEH_PREP.hpp for ${addonName}:`, err);
                        }
                    }

                    await indexer.indexWorkspace();
                    vscode.window.showInformationMessage(
                        `BTC SQF: Completed XEH_PREP.hpp generation. ${updatedCount} updated, ${unchangedCount} already up to date (${totalFunctions} functions total).`
                    );
                }
            );
        })
    );

    // Command to manually re-index
    context.subscriptions.push(
        vscode.commands.registerCommand('btc-sqf.rebuildIndex', async () => {
            await indexer.indexWorkspace();
            const count = indexer.getAllFunctions().length;
            vscode.window.showInformationMessage(`BTC SQF: Reindexed ${count} functions.`);
        })
    );
}

export function deactivate() {
    console.log('[BTC SQF] Deactivated.');
}
