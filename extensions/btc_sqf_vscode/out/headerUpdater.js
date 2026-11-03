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
exports.HeaderUpdater = void 0;
const path = __importStar(require("path"));
const cbaResolver_1 = require("./cbaResolver");
const variableInferrer_1 = require("./variableInferrer");
const docParser_1 = require("./docParser");
const syntaxClassifier_1 = require("./syntaxClassifier");
const TYPE_PROTOTYPE_MAP = {
    '""': 'STRING',
    '\'\'': 'STRING',
    '0': 'NUMBER',
    '123': 'NUMBER',
    'true': 'BOOLEAN',
    'false': 'BOOLEAN',
    '[]': 'ARRAY',
    '[[]]': 'ARRAY',
    'objnull': 'OBJECT',
    'controlnull': 'CONTROL',
    'displaynull': 'DISPLAY',
    'grpnull': 'GROUP',
    'locationnull': 'LOCATION',
    'tasknull': 'TASK',
    'confignull': 'CONFIG',
    '{}': 'CODE',
    'createhashmap': 'HASHMAP',
    'createhashmapfromarray': 'HASHMAP',
    'vector3d': 'ARRAY',
    'sideunknown': 'SIDE',
    'west': 'SIDE',
    'east': 'SIDE',
    'independent': 'SIDE',
    'civilian': 'SIDE',
    'player': 'OBJECT',
    'cursorobject': 'OBJECT',
    'cursortarget': 'OBJECT',
    'cameraon': 'OBJECT',
    'configfile': 'CONFIG',
    'missionconfigfile': 'CONFIG',
    'campaignconfigfile': 'CONFIG'
};
class HeaderUpdater {
    /**
     * Resolves the canonical CBA function name from a file path:
     * prefix_addon_component_fnc_fncname (e.g. btc_toolchain_cas_fnc_list_attributeSave)
     */
    static resolveFunctionName(filePath) {
        const norm = filePath.replace(/\\/g, '/');
        const ctx = cbaResolver_1.CbaResolver.resolveContext(filePath);
        const baseName = path.basename(norm, '.sqf');
        const funcBase = baseName.replace(/^fnc_/, '');
        const match = norm.match(/(?:^|\/)functions\/(.+)$/i);
        if (match) {
            const rel = match[1];
            const subDir = path.dirname(rel);
            if (subDir && subDir !== '.') {
                const folder = subDir.replace(/[\/\\]+/g, '_');
                return `${ctx.prefix}_${ctx.component}_fnc_${folder}_${funcBase}`;
            }
        }
        return `${ctx.prefix}_${ctx.component}_fnc_${funcBase}`;
    }
    /**
     * Normalize type name to standard uppercase or union (e.g. "ARRAY or STRING")
     */
    static normalizeType(typeStr) {
        const clean = typeStr.trim();
        if (!clean)
            return 'ANY';
        if (clean.includes(' | ')) {
            return clean.split(' | ').map(x => this.normalizeType(x)).join(' or ');
        }
        if (clean.includes(' or ')) {
            return clean.split(' or ').map(x => this.normalizeType(x)).join(' or ');
        }
        const upper = clean.toUpperCase();
        if (upper === 'BOOL')
            return 'BOOLEAN';
        if (upper === 'HASH_MAP')
            return 'HASHMAP';
        if (upper === 'WAYPOINT')
            return 'WAYPOINT';
        if (upper === 'VECTOR3D' || upper.startsWith('POSITION3D'))
            return 'ARRAY';
        return upper;
    }
    /**
     * Extract parameters from params [...] statement and format docblock parameters lines,
     * maintaining existing parameter descriptions where available.
     */
    static resolveParameters(content, existingDocParams) {
        const docParamMap = new Map();
        for (const p of existingDocParams) {
            docParamMap.set(p.name.toLowerCase(), p);
        }
        // Mask comments so we do not match example params inside docblocks
        const cleanContent = syntaxClassifier_1.SyntaxClassifier.maskComments(content);
        const match = cleanContent.match(/\bparams\s*\[([\s\S]*?)\]\s*;/i);
        if (!match) {
            const hasNoneInDoc = existingDocParams.length === 0;
            return {
                formattedText: hasNoneInDoc ? '    None' : '    None',
                paramNames: []
            };
        }
        const innerParams = match[1];
        const entries = docParser_1.SqfDocParser.splitTopLevelEntries(innerParams);
        const resultLines = [];
        const paramNames = [];
        for (const entry of entries) {
            const trimmed = entry.trim();
            if (!trimmed)
                continue;
            let varName = '';
            let inferredType = 'ANY';
            let defaultValue;
            if (trimmed.startsWith('[')) {
                const subEntries = docParser_1.SqfDocParser.splitTopLevelEntries(trimmed.slice(1, -1));
                if (subEntries.length > 0) {
                    varName = subEntries[0].trim().replace(/^["']|["']$/g, '');
                    defaultValue = subEntries.length > 1 ? subEntries[1].trim() : undefined;
                    if (subEntries.length > 2) {
                        const typesArr = subEntries[2].trim();
                        inferredType = this.resolveTypesFromArray(typesArr);
                    }
                    else if (defaultValue) {
                        inferredType = this.inferTypeFromDefault(defaultValue);
                    }
                }
            }
            else {
                varName = trimmed.replace(/^["']|["']$/g, '');
            }
            if (!varName)
                continue;
            paramNames.push(varName);
            const docEntry = docParamMap.get(varName.toLowerCase());
            if (inferredType === 'ANY' && docEntry && docEntry.type && docEntry.type !== 'ANY') {
                inferredType = this.normalizeType(docEntry.type);
            }
            const formattedType = this.normalizeType(inferredType);
            if (docEntry && docEntry.description) {
                resultLines.push(`    ${varName}: ${formattedType} - ${docEntry.description}`);
            }
            else {
                resultLines.push(`    ${varName}: ${formattedType}`);
            }
        }
        if (resultLines.length === 0) {
            return {
                formattedText: '    None',
                paramNames: []
            };
        }
        return {
            formattedText: resultLines.join('\n'),
            paramNames
        };
    }
    static resolveTypesFromArray(typesStr) {
        const clean = typesStr.replace(/^\[|\]$/g, '').trim();
        if (!clean)
            return 'ANY';
        const types = docParser_1.SqfDocParser.splitTopLevelEntries(clean)
            .map(t => {
            const norm = t.trim().toLowerCase();
            return TYPE_PROTOTYPE_MAP[norm] || this.normalizeType(t);
        })
            .filter((v, i, a) => a.indexOf(v) === i);
        return types.join(' or ') || 'ANY';
    }
    static inferTypeFromDefault(defVal) {
        const lower = defVal.toLowerCase();
        return TYPE_PROTOTYPE_MAP[lower] || 'ANY';
    }
    /**
     * Resolve the Returns block:
     * - If the last statement ends with a semicolon (;), returns NOTHING.
     * - If missing semicolon, evaluate expression type.
     */
    static resolveReturns(content, existingDocReturns, knownVars, indexer, nativeCommands) {
        const clean = this.getCleanCodeWithoutDocblock(content);
        const { statement, endsWithSemicolon } = this.getLastStatement(clean);
        if (endsWithSemicolon || !statement) {
            return 'NOTHING';
        }
        // Infer expression type
        const inferredType = this.inferExpressionType(statement, clean, existingDocReturns, knownVars, indexer, nativeCommands);
        // Check if existing returns had a description
        const descMatch = existingDocReturns.match(/^([_a-zA-Z0-9\s|]+)\s*(?:[-:]\s*(.+))$/i);
        if (descMatch) {
            const oldType = this.normalizeType(descMatch[1]);
            const oldDesc = descMatch[2].trim();
            if (inferredType === oldType && oldDesc) {
                return `${inferredType} - ${oldDesc}`;
            }
        }
        return inferredType;
    }
    static getCleanCodeWithoutDocblock(content) {
        const text = syntaxClassifier_1.SyntaxClassifier.maskComments(content);
        const lines = text.split('\n');
        const cleanLines = [];
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#'))
                continue;
            cleanLines.push(trimmed);
        }
        return cleanLines.join('\n');
    }
    static getLastStatement(cleanCode) {
        const text = cleanCode.trim();
        if (!text)
            return { statement: '', endsWithSemicolon: true };
        if (text.endsWith(';'))
            return { statement: '', endsWithSemicolon: true };
        let depthBracket = 0;
        let depthBrace = 0;
        let depthParen = 0;
        let inString = false;
        let quoteChar = '';
        let lastSemiIndex = -1;
        for (let i = 0; i < text.length; i++) {
            const ch = text[i];
            if (inString) {
                if (ch === quoteChar)
                    inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quoteChar = ch;
                continue;
            }
            if (ch === '[')
                depthBracket++;
            else if (ch === ']')
                depthBracket--;
            else if (ch === '{')
                depthBrace++;
            else if (ch === '}')
                depthBrace--;
            else if (ch === '(')
                depthParen++;
            else if (ch === ')')
                depthParen--;
            else if (ch === ';' && depthBracket === 0 && depthBrace === 0 && depthParen === 0) {
                lastSemiIndex = i;
            }
        }
        const stmt = lastSemiIndex >= 0 ? text.slice(lastSemiIndex + 1).trim() : text;
        return { statement: stmt, endsWithSemicolon: false };
    }
    static inferExpressionType(expr, fullCleanCode, existingDocReturns, knownVars, indexer, nativeCommands) {
        const s = expr.trim();
        const lower = s.toLowerCase();
        // 1. Boolean unary / comparison / logical
        if (s.startsWith('!') || lower.startsWith('not ')) {
            return 'BOOLEAN';
        }
        if (/\b(?:isEqualTo|isNotEqualTo|isEqualType|isEqualTypeAll|isEqualTypeAny|isEqualTypeParams|in)\b/i.test(s) ||
            s.includes('==') || s.includes('!=') || s.includes('<=') || s.includes('>=') ||
            s.includes('&&') || s.includes('||') || /\b(?:and|or)\b/i.test(s)) {
            return 'BOOLEAN';
        }
        // 2. getOrDefault / getVariable
        const getOrDefaultArgs = variableInferrer_1.VariableTypeInferrer.extractBracketArgs(s, 'getOrDefault');
        if (getOrDefaultArgs !== undefined) {
            const args = docParser_1.SqfDocParser.splitTopLevelEntries(getOrDefaultArgs);
            if (args.length >= 2) {
                return this.inferExpressionType(args[1].trim(), fullCleanCode, '', knownVars, indexer, nativeCommands);
            }
        }
        const getVarArgs = variableInferrer_1.VariableTypeInferrer.extractBracketArgs(s, 'getVariable');
        if (getVarArgs !== undefined) {
            const args = docParser_1.SqfDocParser.splitTopLevelEntries(getVarArgs);
            if (args.length >= 2) {
                return this.inferExpressionType(args[1].trim(), fullCleanCode, '', knownVars, indexer, nativeCommands);
            }
        }
        // 3. Config traversal operator >> and configFile
        if (variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '>>') ||
            lower === 'configfile' || lower === 'missionconfigfile' || lower === 'campaignconfigfile' || lower === 'confignull') {
            return 'CONFIG';
        }
        // Boolean operations (e.g. left isKindOf right)
        if (s.startsWith('!') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isKindOf') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualTo') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualType') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualTypeAll') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualTypeAny') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualTypeArray') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'isEqualTypeParams') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelWordCommand(s, 'in') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '==') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '!=') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '&&') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '||') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '<=') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '>=') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '<') ||
            variableInferrer_1.VariableTypeInferrer.hasTopLevelOperator(s, '>')) {
            return 'BOOLEAN';
        }
        // 4. Literals
        if (s.startsWith('[') && s.endsWith(']'))
            return 'ARRAY';
        if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'")))
            return 'STRING';
        if (lower === 'true' || lower === 'false')
            return 'BOOLEAN';
        if (/^-?(?:0x[0-9a-fA-F]+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)$/.test(s))
            return 'NUMBER';
        if (s.startsWith('{') && s.endsWith('}'))
            return 'CODE';
        if (/\baddWaypoint\b/i.test(s))
            return 'WAYPOINT';
        // 5. Hashmaps / GVAR(table)
        if (lower.startsWith('createhashmap') || /\bGVAR\s*\(\s*table\s*\)/i.test(s) || lower === 'gvar(table)') {
            return 'HASHMAP';
        }
        if (TYPE_PROTOTYPE_MAP[lower]) {
            return TYPE_PROTOTYPE_MAP[lower];
        }
        // 4. Local variable reference
        const singleVarMatch = s.match(/^(_[a-zA-Z0-9_]+)$/);
        if (singleVarMatch) {
            const varName = singleVarMatch[1].toLowerCase();
            const known = knownVars.get(varName);
            if (known && known.type && known.type !== 'Any') {
                return this.normalizeType(known.type);
            }
            // Fallback scan for assignments to this variable in code
            const varRegex = new RegExp(`\\b${singleVarMatch[1]}\\s*=\\s*([^;]+);`, 'gi');
            let vMatch;
            let lastRhs = '';
            while ((vMatch = varRegex.exec(fullCleanCode)) !== null) {
                lastRhs = vMatch[1].trim();
            }
            if (lastRhs) {
                const subType = this.inferExpressionType(lastRhs, fullCleanCode, '', knownVars, indexer, nativeCommands);
                if (subType !== 'ANY')
                    return subType;
            }
        }
        // 5. Function calls: ... call <func>
        const callMatch = s.match(/\bcall\s+([_a-zA-Z0-9]+(?:\([^)]*\))?)\s*$/i);
        if (callMatch) {
            const target = callMatch[1].trim();
            if (/^BIS_fnc_sortBy$/i.test(target))
                return 'ARRAY';
            if (/^BIS_fnc_returnParents$/i.test(target))
                return 'ARRAY';
            if (/^BIS_fnc_admin$/i.test(target))
                return 'NUMBER';
            // EFUNC(tools, getVehicleWeaponsData) or FUNC(callExtension)
            if (indexer) {
                const funcMatch = target.match(/\b(?:E?FUNC|Q?E?FUNC)\s*\(\s*([^,)]+)(?:,\s*([^)]+))?\)/i);
                if (funcMatch) {
                    const shortName = funcMatch[2] ? funcMatch[2].trim() : funcMatch[1].trim();
                    const compName = funcMatch[2] ? funcMatch[1].trim() : undefined;
                    const fnInfo = indexer.findFunction(compName, shortName);
                    if (fnInfo && fnInfo.returns) {
                        const parsed = variableInferrer_1.VariableTypeInferrer.parseReturnType(fnInfo.returns);
                        if (parsed && parsed !== 'Any') {
                            return parsed.toUpperCase();
                        }
                        return this.normalizeType(fnInfo.returns.split(/[-:]/)[0]);
                    }
                }
                else {
                    const fnInfo = indexer.getFunction(target);
                    if (fnInfo && fnInfo.returns) {
                        const parsed = variableInferrer_1.VariableTypeInferrer.parseReturnType(fnInfo.returns);
                        if (parsed && parsed !== 'Any') {
                            return parsed.toUpperCase();
                        }
                        return this.normalizeType(fnInfo.returns.split(/[-:]/)[0]);
                    }
                }
            }
        }
        // 6. Native command lookup
        if (nativeCommands) {
            const topBinary = variableInferrer_1.VariableTypeInferrer.findTopLevelBinaryCommand(s, nativeCommands);
            if (topBinary) {
                const opCmd = nativeCommands.getCommand(topBinary.name);
                if (opCmd && opCmd.syntaxes) {
                    const bin = opCmd.syntaxes.find(syn => syn.callType === 'binary');
                    if (bin && bin.returnType && bin.returnType !== 'Nothing') {
                        return this.normalizeType(bin.returnType);
                    }
                }
            }
            // Check first token for unary command
            const firstToken = s.match(/^([a-zA-Z0-9_]+)\b/);
            if (firstToken) {
                const cmd = nativeCommands.getCommand(firstToken[1]);
                if (cmd && cmd.syntaxes) {
                    const unary = cmd.syntaxes.find(syn => syn.callType === 'unary');
                    if (unary && unary.returnType && unary.returnType !== 'Nothing') {
                        return this.normalizeType(unary.returnType);
                    }
                }
            }
        }
        // 7. Fallback to existing docblock return type if specific
        if (existingDocReturns) {
            const existingType = existingDocReturns.split(/[-:]/)[0].trim();
            if (existingType && existingType !== 'None' && existingType !== 'NOTHING') {
                return this.normalizeType(existingType);
            }
        }
        return 'ANY';
    }
    /**
     * Updates the header docblock of an SQF file in place.
     */
    static updateHeader(filePath, content, indexer, nativeCommands) {
        const newFunctionName = this.resolveFunctionName(filePath);
        const existingDoc = docParser_1.SqfDocParser.parseFile(content);
        // Infer variables for document
        const knownVars = new Map();
        try {
            const lines = content.split('\n');
            for (let i = 0; i < lines.length; i++) {
                const l = lines[i].trim();
                const m = l.match(/(?:private\s+)?(_[a-zA-Z0-9_]+)\s*=\s*([^;]+);?/);
                if (m) {
                    const varName = m[1].toLowerCase();
                    const expr = m[2].trim();
                    const t = variableInferrer_1.VariableTypeInferrer.inferExpressionType(expr, knownVars, nativeCommands);
                    if (!knownVars.has(varName) || knownVars.get(varName).type === 'Any') {
                        knownVars.set(varName, {
                            name: m[1],
                            type: t,
                            line: i,
                            declarationText: l
                        });
                    }
                }
            }
        }
        catch {
            // Ignore
        }
        // Resolve new parameters
        const { formattedText: newParamsText, paramNames: newParams } = this.resolveParameters(content, existingDoc.parameters);
        // Resolve new returns
        const newReturns = this.resolveReturns(content, existingDoc.returns, knownVars, indexer, nativeCommands);
        // Check if docblock exists
        const docRegex = /\/\*\s*[-=]*\s*[\r\n]+([\s\S]*?)\*\//;
        const match = content.match(docRegex);
        let newContent = content;
        const oldFunctionName = existingDoc.functionName;
        const oldReturns = existingDoc.returns;
        const oldParams = existingDoc.parameters.map(p => p.name);
        if (match) {
            let body = match[1];
            // 1. Update Function:
            body = body.replace(/(Function:\s*)([^\r\n]*)/i, `$1${newFunctionName}`);
            // 2. Update Parameters:
            body = body.replace(/Parameters:\s*[\r\n]+[\s\S]*?(?=Returns:)/i, `Parameters:\n${newParamsText}\n\n`);
            // 3. Update Returns:
            body = body.replace(/Returns:\s*[\r\n]+[\s\S]*?(?=(?:Examples:|Author:|\n\s*[-=]{10,}|$))/i, `Returns:\n    ${newReturns}\n\n`);
            // 4. Update Examples: if old function name changed
            if (oldFunctionName && oldFunctionName !== newFunctionName) {
                const exRegex = new RegExp(oldFunctionName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
                body = body.replace(exRegex, newFunctionName);
            }
            newContent = content.slice(0, match.index + match[0].indexOf(match[1])) +
                body +
                content.slice(match.index + match[0].indexOf(match[1]) + match[1].length);
        }
        else {
            // Create a new docblock at top of file
            const newDocblock = `/* ----------------------------------------------------------------------------\n` +
                `Function: ${newFunctionName}\n\n` +
                `Description:\n    TODO: Add description.\n\n` +
                `Parameters:\n${newParamsText}\n\n` +
                `Returns:\n    ${newReturns}\n\n` +
                `Examples:\n    (begin example)\n        [] call ${newFunctionName};\n    (end)\n\n` +
                `Author:\n    =BTC= Fyuran\n\n` +
                `---------------------------------------------------------------------------- */\n`;
            newContent = newDocblock + content;
        }
        const changed = newContent !== content;
        return {
            changed,
            oldFunctionName,
            newFunctionName,
            oldParams,
            newParams,
            oldReturns,
            newReturns,
            newContent
        };
    }
}
exports.HeaderUpdater = HeaderUpdater;
//# sourceMappingURL=headerUpdater.js.map