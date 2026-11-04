import * as fs from 'fs';
import * as path from 'path';
import { ResolvedMacro } from './types';

interface CbaContext {
    prefix: string;
    component: string;
}

export class CbaResolver {
    private static contextCache: Map<string, CbaContext> = new Map();
    private static defaultPrefix = 'myAddon';
    private static defaultComponent = 'main';
    private static addonDirectories: string[] = ['addons'];

    public static setDefaultPrefix(prefix: string) {
        this.defaultPrefix = prefix || 'myAddon';
        this.contextCache.clear();
    }

    public static getDefaultPrefix(): string {
        return this.defaultPrefix;
    }

    public static setDefaultComponent(component: string) {
        this.defaultComponent = component || 'main';
        this.contextCache.clear();
    }

    public static getDefaultComponent(): string {
        return this.defaultComponent;
    }

    public static setAddonDirectories(dirs: string[]) {
        this.addonDirectories = (dirs && dirs.length > 0 ? dirs : ['addons']).map(d => d.toLowerCase());
        this.contextCache.clear();
    }

    public static getAddonDirectories(): string[] {
        return this.addonDirectories;
    }

    public static clearCache(): void {
        this.contextCache.clear();
    }

    public static resolveContext(filePath?: string): CbaContext {
        if (!filePath || !path.isAbsolute(filePath)) {
            return { prefix: this.defaultPrefix, component: this.defaultComponent };
        }

        const dir = path.dirname(filePath);
        if (this.contextCache.has(dir)) {
            return this.contextCache.get(dir)!;
        }

        let component = this.defaultComponent;
        let prefix = this.defaultPrefix;

        // Walk up directory tree to find script_component.hpp or component directory
        let currentDir = dir;
        const root = path.parse(dir).root;

        while (currentDir && currentDir !== root) {
            const parent = path.dirname(currentDir);
            if (parent === currentDir) {
                break;
            }

            // 1. Check for script_component.hpp
            const compHeader = path.join(currentDir, 'script_component.hpp');
            if (fs.existsSync(compHeader)) {
                try {
                    const content = fs.readFileSync(compHeader, 'utf-8');
                    const compMatch = content.match(/#define\s+COMPONENT\s+([_a-zA-Z0-9]+)/i);
                    if (compMatch) {
                        component = compMatch[1];
                    }
                } catch {
                    // Ignore read errors
                }
                break;
            }

            // 2. Check if parent directory matches any configured addon directory name (e.g. addons/cas)
            const parentBase = path.basename(parent).toLowerCase();
            if (this.addonDirectories.includes(parentBase)) {
                component = path.basename(currentDir);
                break;
            }

            // 3. Fallback: If current directory has a functions/ subdirectory, treat currentDir as component
            const funcsCandidate = path.join(currentDir, 'functions');
            if (fs.existsSync(funcsCandidate) && fs.statSync(funcsCandidate).isDirectory()) {
                component = path.basename(currentDir);
            }

            currentDir = parent;
        }

        // Try to find script_mod.hpp to extract PREFIX
        currentDir = dir;
        while (currentDir && currentDir !== root) {
            const parent = path.dirname(currentDir);
            if (parent === currentDir) {
                break;
            }

            const modHeader = path.join(currentDir, 'script_mod.hpp');
            if (fs.existsSync(modHeader)) {
                try {
                    const content = fs.readFileSync(modHeader, 'utf-8');
                    const prefixMatch = content.match(/#define\s+PREFIX\s+([_a-zA-Z0-9]+)/i);
                    if (prefixMatch) {
                        prefix = prefixMatch[1];
                        break;
                    }
                } catch {
                    // Ignore
                }
            }

            // Check configured addon container directories (e.g. addons/main/script_mod.hpp)
            for (const addonDirName of this.addonDirectories) {
                const mainModHeader = path.join(currentDir, addonDirName, 'main', 'script_mod.hpp');
                if (fs.existsSync(mainModHeader)) {
                    try {
                        const content = fs.readFileSync(mainModHeader, 'utf-8');
                        const prefixMatch = content.match(/#define\s+PREFIX\s+([_a-zA-Z0-9]+)/i);
                        if (prefixMatch) {
                            prefix = prefixMatch[1];
                            break;
                        }
                    } catch {
                        // Ignore
                    }
                }
            }

            currentDir = parent;
        }

        const ctx: CbaContext = { prefix, component };
        this.contextCache.set(dir, ctx);
        return ctx;
    }

    public static findMacroAtPosition(line: string, charIndex: number, filePath?: string): ResolvedMacro | undefined {
        const ctx = this.resolveContext(filePath);

        // Regex patterns for CBA macros
        // EFUNC(comp, fnc) or QEFUNC(comp, fnc)
        const efuncRegex = /\b(Q?EFUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
        let match: RegExpExecArray | null;

        while ((match = efuncRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const isQuoted = match[1].startsWith('Q');
                const targetComp = match[2];
                const fncName = match[3];
                const fullName = `${ctx.prefix}_${targetComp}_fnc_${fncName}`;

                return {
                    type: isQuoted ? 'QEFUNC' : 'EFUNC',
                    prefix: ctx.prefix,
                    component: targetComp,
                    name: fncName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // FUNC(fnc) or QFUNC(fnc) or LINKFUNC(fnc)
        const funcRegex = /\b(Q?FUNC|LINKFUNC|DFUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*\)/g;
        while ((match = funcRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const isQuoted = match[1].startsWith('Q');
                const fncName = match[2];
                const fullName = `${ctx.prefix}_${ctx.component}_fnc_${fncName}`;

                return {
                    type: isQuoted ? 'QFUNC' : 'FUNC',
                    prefix: ctx.prefix,
                    component: ctx.component,
                    name: fncName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // PREP_FOLDER(folder, fnc) in XEH_PREP.hpp
        const prepFolderRegex = /\bPREP_FOLDER\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
        while ((match = prepFolderRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const folder = match[1];
                const fncBase = match[2];
                const shortName = `${folder}_${fncBase}`;
                const fullName = `${ctx.prefix}_${ctx.component}_fnc_${shortName}`;

                return {
                    type: 'FUNC',
                    prefix: ctx.prefix,
                    component: ctx.component,
                    name: shortName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // PREP(fnc) in XEH_PREP.hpp
        const prepRegex = /\bPREP\s*\(\s*([_a-zA-Z0-9]+)\s*\)/g;
        while ((match = prepRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const fncName = match[1];
                const fullName = `${ctx.prefix}_${ctx.component}_fnc_${fncName}`;

                return {
                    type: 'FUNC',
                    prefix: ctx.prefix,
                    component: ctx.component,
                    name: fncName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // EGVAR(comp, var) or QEGVAR(comp, var)
        const egvarRegex = /\b(Q?EGVAR)\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
        while ((match = egvarRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const isQuoted = match[1].startsWith('Q');
                const targetComp = match[2];
                const varName = match[3];
                const fullName = `${ctx.prefix}_${targetComp}_${varName}`;

                return {
                    type: isQuoted ? 'QEGVAR' : 'EGVAR',
                    prefix: ctx.prefix,
                    component: targetComp,
                    name: varName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // GVAR(var) or QGVAR(var)
        const gvarRegex = /\b(Q?GVAR)\s*\(\s*([_a-zA-Z0-9]+)\s*\)/g;
        while ((match = gvarRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const isQuoted = match[1].startsWith('Q');
                const varName = match[2];
                const fullName = `${ctx.prefix}_${ctx.component}_${varName}`;

                return {
                    type: isQuoted ? 'QGVAR' : 'GVAR',
                    prefix: ctx.prefix,
                    component: ctx.component,
                    name: varName,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        // Raw function name (e.g. btc_toolchain_cas_fnc_xxx or bis_fnc_xxx)
        const rawFuncRegex = /\b([a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+)\b/g;
        while ((match = rawFuncRegex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (charIndex >= start && charIndex <= end) {
                const fullName = match[1];
                const parts = fullName.split('_fnc_');
                const prefixPart = parts[0] || '';
                const namePart = parts[1] || '';
                const prefixTokens = prefixPart.split('_');
                const comp = prefixTokens.pop() || ctx.component;
                const pref = prefixTokens.join('_') || ctx.prefix;

                return {
                    type: 'RAW_FUNC',
                    prefix: pref,
                    component: comp,
                    name: namePart,
                    fullName,
                    range: { startChar: start, endChar: end }
                };
            }
        }

        return undefined;
    }
}

