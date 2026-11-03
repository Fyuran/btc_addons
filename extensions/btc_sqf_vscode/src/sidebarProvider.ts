import * as vscode from 'vscode';

export class BtcSqfToolItem extends vscode.TreeItem {
    constructor(
        public readonly label: string,
        public readonly description: string,
        public readonly tooltip: string,
        public readonly commandId: string,
        iconName: string,
        public readonly children?: BtcSqfToolItem[]
    ) {
        super(
            label,
            children ? vscode.TreeItemCollapsibleState.Expanded : vscode.TreeItemCollapsibleState.None
        );
        this.iconPath = new vscode.ThemeIcon(iconName);
        if (commandId) {
            this.command = {
                command: commandId,
                title: label
            };
        }
    }
}

export class BtcSqfToolsTreeDataProvider implements vscode.TreeDataProvider<BtcSqfToolItem> {
    private _onDidChangeTreeData: vscode.EventEmitter<BtcSqfToolItem | undefined | void> =
        new vscode.EventEmitter<BtcSqfToolItem | undefined | void>();
    readonly onDidChangeTreeData: vscode.Event<BtcSqfToolItem | undefined | void> =
        this._onDidChangeTreeData.event;

    refresh(): void {
        this._onDidChangeTreeData.fire();
    }

    getTreeItem(element: BtcSqfToolItem): vscode.TreeItem {
        return element;
    }

    getChildren(element?: BtcSqfToolItem): Thenable<BtcSqfToolItem[]> {
        if (!element) {
            return Promise.resolve([
                new BtcSqfToolItem(
                    'Update Header (Active File)',
                    'Current SQF',
                    'Parse current SQF file and adjust Function, Parameters, and Returns blocks in the comment header',
                    'btc-sqf.updateCurrentHeader',
                    'file-code'
                ),
                new BtcSqfToolItem(
                    'Update All Headers (Workspace)',
                    'Batch all fnc_*.sqf',
                    'Scan all fnc_*.sqf in workspace and synchronize their comment headers',
                    'btc-sqf.updateAllHeaders',
                    'files'
                ),
                new BtcSqfToolItem(
                    'Generate XEH_PREP.hpp (Current Component)',
                    'PREP & PREP_FOLDER',
                    'Construct or update XEH_PREP.hpp for the current addon component',
                    'btc-sqf.generateCurrentXehPrep',
                    'file-submodule'
                ),
                new BtcSqfToolItem(
                    'Generate All XEH_PREP.hpp (Workspace)',
                    'Batch all addons',
                    'Construct or update XEH_PREP.hpp for all components in workspace',
                    'btc-sqf.generateAllXehPrep',
                    'folder-library'
                ),
                new BtcSqfToolItem(
                    'Reindex Functions',
                    'Refresh cache',
                    'Scan workspace to refresh function definitions and signatures',
                    'btc-sqf.rebuildIndex',
                    'refresh'
                )
            ]);
        }
        return Promise.resolve(element.children || []);
    }
}

