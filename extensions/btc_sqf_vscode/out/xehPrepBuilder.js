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
exports.XehPrepBuilder = void 0;
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
class XehPrepBuilder {
    /**
     * Resolves the addon root directory from any file path inside the addon.
     * Walks up the directory tree looking for script_component.hpp, XEH_PREP.hpp,
     * or a direct child of an 'addons' folder.
     */
    static resolveAddonDir(filePath) {
        let current = fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()
            ? filePath
            : path.dirname(filePath);
        const root = path.parse(current).root;
        while (current !== root) {
            // Check if directory has script_component.hpp or XEH_PREP.hpp or functions/
            if (fs.existsSync(path.join(current, 'script_component.hpp')) ||
                fs.existsSync(path.join(current, 'XEH_PREP.hpp')) ||
                fs.existsSync(path.join(current, 'functions'))) {
                return current;
            }
            // Check if parent directory is 'addons'
            const parent = path.dirname(current);
            if (path.basename(parent).toLowerCase() === 'addons') {
                return current;
            }
            current = parent;
        }
        return undefined;
    }
    /**
     * Builds the content of XEH_PREP.hpp for a given addon directory.
     * Files directly in functions/ use PREP(fncname);
     * Files in subfolders of functions/ use PREP_FOLDER(folder,fncname);
     */
    static buildXehPrepContent(addonDir) {
        const funcsDir = path.join(addonDir, 'functions');
        if (!fs.existsSync(funcsDir) || !fs.statSync(funcsDir).isDirectory()) {
            return undefined;
        }
        const prepFile = path.join(addonDir, 'XEH_PREP.hpp');
        let existingContent = '';
        if (fs.existsSync(prepFile)) {
            try {
                existingContent = fs.readFileSync(prepFile, 'utf-8');
            }
            catch {
                existingContent = '';
            }
        }
        const hasIsDedicated = /isDedicated/i.test(existingContent);
        const indent = hasIsDedicated ? '\t' : '';
        // Extract any custom non-PREP statements to preserve them (e.g. CBAFUNC(...) = ...)
        const customLines = [];
        const customReferencedFuncs = new Set();
        if (existingContent) {
            const rawLines = existingContent.split('\n');
            for (const line of rawLines) {
                const s = line.trim();
                if (!s || s.startsWith('//') || s.startsWith('#include') ||
                    s.startsWith('if(') || s.startsWith('if (') || s === '};') {
                    continue;
                }
                if (/^PREP\s*\([^)]+\)\s*;?$/i.test(s))
                    continue;
                if (/^PREP_FOLDER\s*\([^)]+\)\s*;?$/i.test(s))
                    continue;
                customLines.push(s);
                // Check if line references a function file (e.g. fnc_cba_debug2.sqf)
                const m = s.match(/fnc_([a-zA-Z0-9_]+)\.sqf/i);
                if (m) {
                    customReferencedFuncs.add(m[1].toLowerCase());
                }
            }
        }
        // 1. Root functions directly in functions/
        const rootFuncs = [];
        const subfolderFuncs = new Map();
        let totalFunctions = 0;
        try {
            const entries = fs.readdirSync(funcsDir);
            for (const entry of entries) {
                const fullEntryPath = path.join(funcsDir, entry);
                const stat = fs.statSync(fullEntryPath);
                if (stat.isFile() && entry.startsWith('fnc_') && entry.endsWith('.sqf')) {
                    const fname = entry.slice(4, -4);
                    if (!customReferencedFuncs.has(fname.toLowerCase())) {
                        rootFuncs.push(fname);
                        totalFunctions++;
                    }
                }
                else if (stat.isDirectory()) {
                    const subEntries = fs.readdirSync(fullEntryPath);
                    const subList = [];
                    for (const subEntry of subEntries) {
                        const subPath = path.join(fullEntryPath, subEntry);
                        const subStat = fs.statSync(subPath);
                        if (subStat.isFile() && subEntry.startsWith('fnc_') && subEntry.endsWith('.sqf')) {
                            const fname = subEntry.slice(4, -4);
                            if (!customReferencedFuncs.has(fname.toLowerCase())) {
                                subList.push(fname);
                                totalFunctions++;
                            }
                        }
                    }
                    if (subList.length > 0) {
                        subList.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }));
                        subfolderFuncs.set(entry, subList);
                    }
                }
            }
        }
        catch (err) {
            console.error(`[BTC SQF] Failed to read functions directory ${funcsDir}:`, err);
            return undefined;
        }
        rootFuncs.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }));
        // Construct content
        const lines = [
            '#include "script_component.hpp"',
            ''
        ];
        if (hasIsDedicated) {
            lines.push('if(!isDedicated) then {');
        }
        // Direct functions in functions/ -> PREP(fncname);
        if (rootFuncs.length > 0) {
            for (const rf of rootFuncs) {
                lines.push(`${indent}PREP(${rf});`);
            }
            lines.push('');
        }
        // Preserved custom lines
        if (customLines.length > 0) {
            for (const cl of customLines) {
                lines.push(`${indent}${cl}`);
            }
            lines.push('');
        }
        // Subfolders -> PREP_FOLDER(folder,fncname);
        const sortedFolders = Array.from(subfolderFuncs.keys()).sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }));
        for (const folder of sortedFolders) {
            lines.push(`${indent}// ${folder}`);
            const list = subfolderFuncs.get(folder);
            for (const fnc of list) {
                lines.push(`${indent}PREP_FOLDER(${folder},${fnc});`);
            }
            lines.push('');
        }
        if (hasIsDedicated) {
            lines.push('};');
            lines.push('');
        }
        const formatted = lines.join('\n').trimEnd() + '\n';
        return {
            content: formatted,
            totalFunctions
        };
    }
    /**
     * Constructs or updates XEH_PREP.hpp for the specified file path or addon directory.
     */
    static buildXehPrep(filePathOrAddonDir) {
        const addonDir = this.resolveAddonDir(filePathOrAddonDir);
        if (!addonDir) {
            return undefined;
        }
        const buildRes = this.buildXehPrepContent(addonDir);
        if (!buildRes) {
            return undefined;
        }
        const targetFilePath = path.join(addonDir, 'XEH_PREP.hpp');
        let oldContent;
        if (fs.existsSync(targetFilePath)) {
            try {
                oldContent = fs.readFileSync(targetFilePath, 'utf-8');
            }
            catch {
                oldContent = undefined;
            }
        }
        const changed = oldContent !== buildRes.content;
        const addonName = path.basename(addonDir);
        return {
            addonDir,
            addonName,
            targetFilePath,
            changed,
            oldContent,
            newContent: buildRes.content,
            functionsFound: buildRes.totalFunctions
        };
    }
}
exports.XehPrepBuilder = XehPrepBuilder;
//# sourceMappingURL=xehPrepBuilder.js.map