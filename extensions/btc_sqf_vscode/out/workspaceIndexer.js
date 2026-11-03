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
exports.WorkspaceIndexer = void 0;
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const docParser_1 = require("./docParser");
const cbaResolver_1 = require("./cbaResolver");
class WorkspaceIndexer {
    functionsByFullName = new Map();
    functionsByCompAndName = new Map();
    functionsByShortName = new Map();
    fileToFunctionMap = new Map();
    async indexWorkspace() {
        this.functionsByFullName.clear();
        this.functionsByCompAndName.clear();
        this.functionsByShortName.clear();
        this.fileToFunctionMap.clear();
        const sqfFiles = await vscode.workspace.findFiles('**/fnc_*.sqf', '**/node_modules/**');
        for (const uri of sqfFiles) {
            this.indexFile(uri.fsPath);
        }
        // Also scan XEH_PREP.hpp files to discover folder-prefixed mappings
        const prepFiles = await vscode.workspace.findFiles('**/XEH_PREP.hpp', '**/node_modules/**');
        for (const uri of prepFiles) {
            this.indexXehPrep(uri.fsPath);
        }
    }
    indexFile(filePath) {
        try {
            if (!fs.existsSync(filePath))
                return undefined;
            const content = fs.readFileSync(filePath, 'utf-8');
            const doc = docParser_1.SqfDocParser.parseFile(content);
            const ctx = cbaResolver_1.CbaResolver.resolveContext(filePath);
            const baseName = path.basename(filePath, '.sqf');
            let funcBaseName = baseName.replace(/^fnc_/, '');
            // Check if file is inside a subfolder under functions/ (e.g. functions/list/fnc_attributeLoad.sqf)
            const parentDir = path.basename(path.dirname(filePath));
            const grandParentDir = path.basename(path.dirname(path.dirname(filePath)));
            let resolvedShortName = funcBaseName;
            if (grandParentDir.toLowerCase() === 'functions' && parentDir.toLowerCase() !== 'functions') {
                // Inside functions/<folder>/fnc_<name>.sqf -> name is <folder>_<name>
                resolvedShortName = `${parentDir}_${funcBaseName}`;
            }
            const fullName = doc.functionName || `${ctx.prefix}_${ctx.component}_fnc_${resolvedShortName}`;
            const info = {
                fullName,
                shortName: resolvedShortName,
                component: ctx.component,
                prefix: ctx.prefix,
                filePath,
                description: doc.description,
                parameters: doc.parameters,
                returns: doc.returns,
                example: doc.example,
                author: doc.author
            };
            this.registerFunction(info);
            // Also register under the unprefixed name if different (e.g. fnc_initVehicleData)
            if (funcBaseName !== resolvedShortName) {
                const altKey = `${ctx.component.toLowerCase()}:${funcBaseName.toLowerCase()}`;
                if (!this.functionsByCompAndName.has(altKey)) {
                    this.functionsByCompAndName.set(altKey, info);
                }
            }
            return info;
        }
        catch (err) {
            console.error(`[BTC SQF] Failed to index ${filePath}:`, err);
            return undefined;
        }
    }
    registerFunction(info) {
        const fullLower = info.fullName.toLowerCase();
        this.functionsByFullName.set(fullLower, info);
        const compKey = `${info.component.toLowerCase()}:${info.shortName.toLowerCase()}`;
        this.functionsByCompAndName.set(compKey, info);
        const shortLower = info.shortName.toLowerCase();
        let list = this.functionsByShortName.get(shortLower);
        if (!list) {
            list = [];
            this.functionsByShortName.set(shortLower, list);
        }
        list.push(info);
        this.fileToFunctionMap.set(info.filePath, fullLower);
    }
    indexXehPrep(filePath) {
        try {
            if (!fs.existsSync(filePath))
                return;
            const content = fs.readFileSync(filePath, 'utf-8');
            const addonDir = path.dirname(filePath);
            const ctx = cbaResolver_1.CbaResolver.resolveContext(filePath);
            // PREP_FOLDER(folder, fncName);
            const folderRegex = /PREP_FOLDER\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
            let match;
            while ((match = folderRegex.exec(content)) !== null) {
                const folder = match[1];
                const fncName = match[2];
                const targetFile = path.join(addonDir, 'functions', folder, `fnc_${fncName}.sqf`);
                if (fs.existsSync(targetFile)) {
                    const info = this.indexFile(targetFile);
                    if (info) {
                        const expectedShortName = `${folder}_${fncName}`;
                        info.shortName = expectedShortName;
                        info.fullName = `${ctx.prefix}_${ctx.component}_fnc_${expectedShortName}`;
                        this.registerFunction(info);
                    }
                }
            }
            // PREP(fncName);
            const prepRegex = /PREP\s*\(\s*([_a-zA-Z0-9]+)\s*\)/g;
            while ((match = prepRegex.exec(content)) !== null) {
                const fncName = match[1];
                const targetFile = path.join(addonDir, 'functions', `fnc_${fncName}.sqf`);
                if (fs.existsSync(targetFile)) {
                    this.indexFile(targetFile);
                }
            }
        }
        catch (err) {
            console.error(`[BTC SQF] Failed to parse ${filePath}:`, err);
        }
    }
    findFunction(component, name, fullName) {
        if (fullName) {
            const found = this.functionsByFullName.get(fullName.toLowerCase());
            if (found)
                return found;
        }
        if (component && name) {
            const compKey = `${component.toLowerCase()}:${name.toLowerCase()}`;
            const found = this.functionsByCompAndName.get(compKey);
            if (found)
                return found;
        }
        if (name) {
            const list = this.functionsByShortName.get(name.toLowerCase());
            if (list && list.length > 0) {
                if (component) {
                    const match = list.find(f => f.component.toLowerCase() === component.toLowerCase());
                    if (match)
                        return match;
                }
                return list[0];
            }
        }
        return undefined;
    }
    getFunction(nameOrFullName) {
        return this.findFunction(undefined, undefined, nameOrFullName) || this.findFunction(undefined, nameOrFullName);
    }
    getAllFunctions() {
        return Array.from(this.functionsByFullName.values());
    }
    getFunctionsByComponent(component) {
        const compLower = component.toLowerCase();
        return Array.from(this.functionsByFullName.values()).filter(f => f.component.toLowerCase() === compLower);
    }
    getAllComponents() {
        const set = new Set();
        for (const f of this.functionsByFullName.values()) {
            if (f.component)
                set.add(f.component);
        }
        return Array.from(set).sort();
    }
}
exports.WorkspaceIndexer = WorkspaceIndexer;
//# sourceMappingURL=workspaceIndexer.js.map