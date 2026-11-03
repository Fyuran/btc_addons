import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { CustomFunctionInfo } from './types';
import { SqfDocParser } from './docParser';
import { CbaResolver } from './cbaResolver';

export class WorkspaceIndexer {
    private functionsByFullName: Map<string, CustomFunctionInfo> = new Map();
    private functionsByCompAndName: Map<string, CustomFunctionInfo> = new Map();
    private functionsByShortName: Map<string, CustomFunctionInfo[]> = new Map();
    private fileToFunctionMap: Map<string, string> = new Map();

    public async indexWorkspace(): Promise<void> {
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

    public indexFile(filePath: string): CustomFunctionInfo | undefined {
        try {
            if (!fs.existsSync(filePath)) return undefined;

            const content = fs.readFileSync(filePath, 'utf-8');
            const doc = SqfDocParser.parseFile(content);
            const ctx = CbaResolver.resolveContext(filePath);

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

            const info: CustomFunctionInfo = {
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
        } catch (err) {
            console.error(`[BTC SQF] Failed to index ${filePath}:`, err);
            return undefined;
        }
    }

    private registerFunction(info: CustomFunctionInfo) {
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

    public indexXehPrep(filePath: string): void {
        try {
            if (!fs.existsSync(filePath)) return;
            const content = fs.readFileSync(filePath, 'utf-8');
            const addonDir = path.dirname(filePath);
            const ctx = CbaResolver.resolveContext(filePath);

            // PREP_FOLDER(folder, fncName);
            const folderRegex = /PREP_FOLDER\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
            let match: RegExpExecArray | null;

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
        } catch (err) {
            console.error(`[BTC SQF] Failed to parse ${filePath}:`, err);
        }
    }

    public findFunction(component?: string, name?: string, fullName?: string): CustomFunctionInfo | undefined {
        if (fullName) {
            const found = this.functionsByFullName.get(fullName.toLowerCase());
            if (found) return found;
        }

        if (component && name) {
            const compKey = `${component.toLowerCase()}:${name.toLowerCase()}`;
            const found = this.functionsByCompAndName.get(compKey);
            if (found) return found;
        }

        if (name) {
            const list = this.functionsByShortName.get(name.toLowerCase());
            if (list && list.length > 0) {
                if (component) {
                    const match = list.find(f => f.component.toLowerCase() === component.toLowerCase());
                    if (match) return match;
                }
                return list[0];
            }
        }

        return undefined;
    }

    public getFunction(nameOrFullName: string): CustomFunctionInfo | undefined {
        return this.findFunction(undefined, undefined, nameOrFullName) || this.findFunction(undefined, nameOrFullName);
    }

    public getAllFunctions(): CustomFunctionInfo[] {
        return Array.from(this.functionsByFullName.values());
    }

    public getFunctionsByComponent(component: string): CustomFunctionInfo[] {
        const compLower = component.toLowerCase();
        return Array.from(this.functionsByFullName.values()).filter(
            f => f.component.toLowerCase() === compLower
        );
    }

    public getAllComponents(): string[] {
        const set = new Set<string>();
        for (const f of this.functionsByFullName.values()) {
            if (f.component) set.add(f.component);
        }
        return Array.from(set).sort();
    }
}
