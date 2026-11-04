import * as path from 'path';
import * as fs from 'fs';
import { CbaResolver } from './cbaResolver';

export interface XehPrepBuildResult {
    addonDir: string;
    addonName: string;
    targetFilePath: string;
    changed: boolean;
    oldContent?: string;
    newContent: string;
    functionsFound: number;
}

export class XehPrepBuilder {
    /**
     * Resolves the addon root directory from any file path inside the addon.
     * Walks up the directory tree looking for script_component.hpp, XEH_PREP.hpp,
     * or a direct child of configured addon directories.
     */
    public static resolveAddonDir(filePath?: string): string | undefined {
        if (!filePath || !path.isAbsolute(filePath)) {
            return undefined;
        }

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

            // Check if parent directory matches configured addon directories
            const parent = path.dirname(current);
            if (parent === current) {
                break;
            }

            const addonDirs = CbaResolver.getAddonDirectories();
            if (addonDirs.includes(path.basename(parent).toLowerCase())) {
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
    public static buildXehPrepContent(addonDir: string): { content: string; totalFunctions: number } | undefined {
        const funcsDir = path.join(addonDir, 'functions');
        if (!fs.existsSync(funcsDir) || !fs.statSync(funcsDir).isDirectory()) {
            return undefined;
        }

        const prepFile = path.join(addonDir, 'XEH_PREP.hpp');
        let existingContent = '';
        if (fs.existsSync(prepFile)) {
            try {
                existingContent = fs.readFileSync(prepFile, 'utf-8');
            } catch {
                existingContent = '';
            }
        }

        const hasIsDedicated = /isDedicated/i.test(existingContent);
        const indent = hasIsDedicated ? '\t' : '';

        // Extract any custom non-PREP statements to preserve them (e.g. CBAFUNC(...) = ...)
        const customLines: string[] = [];
        const customReferencedFuncs = new Set<string>();

        if (existingContent) {
            const rawLines = existingContent.split('\n');
            for (const line of rawLines) {
                const s = line.trim();
                if (!s || s.startsWith('//') || s.startsWith('#include') ||
                    s.startsWith('if(') || s.startsWith('if (') || s === '};') {
                    continue;
                }
                if (/^PREP\s*\([^)]+\)\s*;?$/i.test(s)) continue;
                if (/^PREP_FOLDER\s*\([^)]+\)\s*;?$/i.test(s)) continue;

                customLines.push(s);

                // Check if line references a function file (e.g. fnc_cba_debug2.sqf)
                const m = s.match(/fnc_([a-zA-Z0-9_]+)\.sqf/i);
                if (m) {
                    customReferencedFuncs.add(m[1].toLowerCase());
                }
            }
        }

        // 1. Root functions directly in functions/
        const rootFuncs: string[] = [];
        const subfolderFuncs = new Map<string, string[]>();
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
                } else if (stat.isDirectory()) {
                    const subEntries = fs.readdirSync(fullEntryPath);
                    const subList: string[] = [];
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
        } catch (err) {
            console.error(`[BTC SQF] Failed to read functions directory ${funcsDir}:`, err);
            return undefined;
        }

        rootFuncs.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }));

        // Construct content
        const lines: string[] = [
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
        const sortedFolders = Array.from(subfolderFuncs.keys()).sort((a, b) =>
            a.localeCompare(b, undefined, { sensitivity: 'base' })
        );

        for (const folder of sortedFolders) {
            lines.push(`${indent}// ${folder}`);
            const list = subfolderFuncs.get(folder)!;
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
    public static buildXehPrep(filePathOrAddonDir: string): XehPrepBuildResult | undefined {
        const addonDir = this.resolveAddonDir(filePathOrAddonDir);
        if (!addonDir) {
            return undefined;
        }

        const buildRes = this.buildXehPrepContent(addonDir);
        if (!buildRes) {
            return undefined;
        }

        const targetFilePath = path.join(addonDir, 'XEH_PREP.hpp');
        let oldContent: string | undefined;
        if (fs.existsSync(targetFilePath)) {
            try {
                oldContent = fs.readFileSync(targetFilePath, 'utf-8');
            } catch {
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

