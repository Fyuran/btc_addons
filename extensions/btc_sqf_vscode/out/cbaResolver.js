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
exports.CbaResolver = void 0;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
class CbaResolver {
    static contextCache = new Map();
    static defaultPrefix = 'myAddon';
    static defaultComponent = 'main';
    static addonDirectories = ['addons'];
    static setDefaultPrefix(prefix) {
        this.defaultPrefix = prefix || 'myAddon';
        this.contextCache.clear();
    }
    static getDefaultPrefix() {
        return this.defaultPrefix;
    }
    static setDefaultComponent(component) {
        this.defaultComponent = component || 'main';
        this.contextCache.clear();
    }
    static getDefaultComponent() {
        return this.defaultComponent;
    }
    static setAddonDirectories(dirs) {
        this.addonDirectories = (dirs && dirs.length > 0 ? dirs : ['addons']).map(d => d.toLowerCase());
        this.contextCache.clear();
    }
    static getAddonDirectories() {
        return this.addonDirectories;
    }
    static clearCache() {
        this.contextCache.clear();
    }
    static resolveContext(filePath) {
        if (!filePath || !path.isAbsolute(filePath)) {
            return { prefix: this.defaultPrefix, component: this.defaultComponent };
        }
        const dir = path.dirname(filePath);
        if (this.contextCache.has(dir)) {
            return this.contextCache.get(dir);
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
                }
                catch {
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
                }
                catch {
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
                    }
                    catch {
                        // Ignore
                    }
                }
            }
            currentDir = parent;
        }
        const ctx = { prefix, component };
        this.contextCache.set(dir, ctx);
        return ctx;
    }
    static findMacroAtPosition(line, charIndex, filePath) {
        const ctx = this.resolveContext(filePath);
        // Regex patterns for CBA macros
        // EFUNC(comp, fnc) or QEFUNC(comp, fnc)
        const efuncRegex = /\b(Q?EFUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]+)\s*\)/g;
        let match;
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
exports.CbaResolver = CbaResolver;
//# sourceMappingURL=cbaResolver.js.map