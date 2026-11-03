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
exports.BtcSqfToolsTreeDataProvider = exports.BtcSqfToolItem = void 0;
const vscode = __importStar(require("vscode"));
class BtcSqfToolItem extends vscode.TreeItem {
    label;
    description;
    tooltip;
    commandId;
    children;
    constructor(label, description, tooltip, commandId, iconName, children) {
        super(label, children ? vscode.TreeItemCollapsibleState.Expanded : vscode.TreeItemCollapsibleState.None);
        this.label = label;
        this.description = description;
        this.tooltip = tooltip;
        this.commandId = commandId;
        this.children = children;
        this.iconPath = new vscode.ThemeIcon(iconName);
        if (commandId) {
            this.command = {
                command: commandId,
                title: label
            };
        }
    }
}
exports.BtcSqfToolItem = BtcSqfToolItem;
class BtcSqfToolsTreeDataProvider {
    _onDidChangeTreeData = new vscode.EventEmitter();
    onDidChangeTreeData = this._onDidChangeTreeData.event;
    refresh() {
        this._onDidChangeTreeData.fire();
    }
    getTreeItem(element) {
        return element;
    }
    getChildren(element) {
        if (!element) {
            return Promise.resolve([
                new BtcSqfToolItem('Update Header (Active File)', 'Current SQF', 'Parse current SQF file and adjust Function, Parameters, and Returns blocks in the comment header', 'btc-sqf.updateCurrentHeader', 'file-code'),
                new BtcSqfToolItem('Update All Headers (Workspace)', 'Batch all fnc_*.sqf', 'Scan all fnc_*.sqf in workspace and synchronize their comment headers', 'btc-sqf.updateAllHeaders', 'files'),
                new BtcSqfToolItem('Generate XEH_PREP.hpp (Current Component)', 'PREP & PREP_FOLDER', 'Construct or update XEH_PREP.hpp for the current addon component', 'btc-sqf.generateCurrentXehPrep', 'file-submodule'),
                new BtcSqfToolItem('Generate All XEH_PREP.hpp (Workspace)', 'Batch all addons', 'Construct or update XEH_PREP.hpp for all components in workspace', 'btc-sqf.generateAllXehPrep', 'folder-library'),
                new BtcSqfToolItem('Reindex Functions', 'Refresh cache', 'Scan workspace to refresh function definitions and signatures', 'btc-sqf.rebuildIndex', 'refresh')
            ]);
        }
        return Promise.resolve(element.children || []);
    }
}
exports.BtcSqfToolsTreeDataProvider = BtcSqfToolsTreeDataProvider;
//# sourceMappingURL=sidebarProvider.js.map