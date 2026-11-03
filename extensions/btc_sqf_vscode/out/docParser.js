"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SqfDocParser = void 0;
const syntaxClassifier_1 = require("./syntaxClassifier");
const TYPE_PROTOTYPE_MAP = {
    '""': 'STRING',
    '\'\'': 'STRING',
    '0': 'NUMBER',
    '123': 'NUMBER',
    'true': 'BOOLEAN',
    'false': 'BOOLEAN',
    '[]': 'ARRAY',
    'objnull': 'OBJECT',
    'controlnull': 'CONTROL',
    'displaynull': 'DISPLAY',
    'grpnull': 'GROUP',
    'locationnull': 'LOCATION',
    'tasknull': 'TASK',
    'confignull': 'CONFIG',
    '{}': 'CODE',
    'createhashmap': 'HASHMAP',
    'sideunknown': 'SIDE',
    'west': 'SIDE',
    'east': 'SIDE',
    'independent': 'SIDE',
    'civilian': 'SIDE'
};
class SqfDocParser {
    static parseFile(content) {
        const docblock = this.extractDocblock(content);
        const paramsDeclaration = this.extractParamsStatement(content);
        // Merge parameters: docblock descriptions + params types & defaults
        const mergedParams = this.mergeParams(docblock.parameters, paramsDeclaration);
        return {
            functionName: docblock.functionName,
            description: docblock.description.trim(),
            parameters: mergedParams,
            returns: docblock.returns.trim(),
            example: docblock.example?.trim(),
            author: docblock.author?.trim()
        };
    }
    static extractDocblock(content) {
        const result = {
            description: '',
            parameters: [],
            returns: ''
        };
        const commentRegex = /\/\*\s*[-=]*\s*[\r\n]+([\s\S]*?)\*\//;
        const match = content.match(commentRegex);
        if (!match) {
            return result;
        }
        const commentBody = match[1];
        // 1. Function name
        const fnMatch = commentBody.match(/Function:\s*([^\r\n]+)/i);
        if (fnMatch) {
            result.functionName = fnMatch[1].trim();
        }
        // 2. Author
        const authorMatch = commentBody.match(/Author:\s*([^\r\n]+)/i);
        if (authorMatch) {
            result.author = authorMatch[1].trim();
        }
        // 3. Description
        const descMatch = commentBody.match(/Description:\s*([\s\S]*?)(?=(?:Parameters:|Returns:|Examples:|Author:|\n\s*[-=]{10,}|$))/i);
        if (descMatch) {
            result.description = this.cleanSectionText(descMatch[1]);
        }
        // 4. Returns
        const retMatch = commentBody.match(/Returns:\s*([\s\S]*?)(?=(?:Examples:|Author:|\n\s*[-=]{10,}|$))/i);
        if (retMatch) {
            result.returns = this.cleanSectionText(retMatch[1]);
        }
        // 5. Example
        const exMatch = commentBody.match(/Examples:\s*([\s\S]*?)(?=(?:Author:|\n\s*[-=]{10,}|$))/i);
        if (exMatch) {
            let exText = exMatch[1].replace(/\(begin example\)/gi, '').replace(/\(end\)/gi, '');
            result.example = exText.trim();
        }
        // 6. Parameters
        const paramMatch = commentBody.match(/Parameters:\s*([\s\S]*?)(?=(?:Returns:|Examples:|Author:|\n\s*[-=]{10,}|$))/i);
        if (paramMatch) {
            result.parameters = this.parseDocblockParams(paramMatch[1]);
        }
        return result;
    }
    static cleanSectionText(text) {
        return text
            .split('\n')
            .map(line => line.replace(/^\s*\*\s?/, '').trim())
            .filter(line => line.length > 0)
            .join(' ');
    }
    static parseDocblockParams(paramText) {
        const params = [];
        const lines = paramText.split('\n');
        for (const line of lines) {
            const trimmed = line.trim().replace(/^[-*]\s*/, '');
            if (!trimmed)
                continue;
            // Pattern: _param: TYPE - Description
            // or: _param (TYPE) - Description
            // or: _param - Description
            const m = trimmed.match(/^([_a-zA-Z0-9]+)\s*(?::|\(([^)]+)\))\s*([^-\r\n]*?)\s*-\s*(.+)$/i);
            if (m) {
                const name = m[1];
                let type = (m[2] || m[3] || 'ANY').trim().toUpperCase();
                const desc = m[4].trim();
                const optional = /optional/i.test(desc) || /default:/i.test(desc);
                let defaultValue;
                const defMatch = desc.match(/default:\s*([^)]+)\)?/i);
                if (defMatch) {
                    defaultValue = defMatch[1].trim();
                }
                params.push({
                    name,
                    type,
                    description: desc,
                    defaultValue,
                    optional
                });
                continue;
            }
            // Simpler pattern: _param: TYPE
            const mSimple = trimmed.match(/^([_a-zA-Z0-9]+)\s*:\s*([^-\r\n]+)$/i);
            if (mSimple) {
                params.push({
                    name: mSimple[1],
                    type: mSimple[2].trim().toUpperCase()
                });
            }
        }
        return params;
    }
    static extractParamsStatement(content) {
        const params = [];
        // Mask comments so we never parse params inside comment blocks or docblock examples
        const cleanContent = syntaxClassifier_1.SyntaxClassifier.maskComments(content);
        const match = cleanContent.match(/params\s*\[([\s\S]*?)\]\s*;/i);
        if (!match) {
            return params;
        }
        const body = match[1];
        // Parse array elements: either string "_param" or array ["_param", default, [types]]
        const entries = this.splitTopLevelEntries(body);
        for (const entry of entries) {
            const trimmed = entry.trim();
            if (!trimmed)
                continue;
            if (trimmed.startsWith('[')) {
                // Array format: ["_name", defaultValue, [allowedTypes]]
                const inner = trimmed.slice(1, -1).trim();
                const subEntries = this.splitTopLevelEntries(inner);
                if (subEntries.length > 0) {
                    const rawName = subEntries[0].trim().replace(/^["']|["']$/g, '');
                    const defaultValue = subEntries.length > 1 ? subEntries[1].trim() : undefined;
                    let type = 'ANY';
                    if (subEntries.length > 2) {
                        const typesArr = subEntries[2].trim();
                        type = this.resolveTypesFromArray(typesArr);
                    }
                    else if (defaultValue) {
                        type = this.inferTypeFromDefault(defaultValue);
                    }
                    params.push({
                        name: rawName,
                        type,
                        defaultValue,
                        optional: defaultValue !== undefined
                    });
                }
            }
            else if (trimmed.startsWith('"') || trimmed.startsWith('\'')) {
                // Simple string: "_name"
                const name = trimmed.replace(/^["']|["']$/g, '');
                params.push({
                    name,
                    type: 'ANY',
                    optional: false
                });
            }
        }
        return params;
    }
    static resolveTypesFromArray(typesStr) {
        const clean = typesStr.replace(/^\[|\]$/g, '').trim();
        if (!clean)
            return 'ANY';
        const types = this.splitTopLevelEntries(clean)
            .map(t => {
            const norm = t.trim().toLowerCase();
            return TYPE_PROTOTYPE_MAP[norm] || t.trim().toUpperCase();
        })
            .filter((v, i, a) => a.indexOf(v) === i);
        return types.join(' | ') || 'ANY';
    }
    static inferTypeFromDefault(defVal) {
        const lower = defVal.toLowerCase();
        return TYPE_PROTOTYPE_MAP[lower] || 'ANY';
    }
    static splitTopLevelEntries(str) {
        const result = [];
        let current = '';
        let depthBracket = 0;
        let inString = false;
        let quoteChar = '';
        for (let i = 0; i < str.length; i++) {
            const ch = str[i];
            if (inString) {
                current += ch;
                if (ch === quoteChar) {
                    inString = false;
                }
                continue;
            }
            if (ch === '"' || ch === '\'') {
                inString = true;
                quoteChar = ch;
                current += ch;
                continue;
            }
            if (ch === '[' || ch === '{' || ch === '(') {
                depthBracket++;
                current += ch;
            }
            else if (ch === ']' || ch === '}' || ch === ')') {
                depthBracket--;
                current += ch;
            }
            else if (ch === ',' && depthBracket === 0) {
                result.push(current.trim());
                current = '';
            }
            else {
                current += ch;
            }
        }
        if (current.trim()) {
            result.push(current.trim());
        }
        return result;
    }
    static mergeParams(docParams, codeParams) {
        if (codeParams.length === 0) {
            return docParams;
        }
        const merged = [];
        const docMap = new Map();
        for (const dp of docParams) {
            docMap.set(dp.name.toLowerCase(), dp);
        }
        for (const cp of codeParams) {
            const doc = docMap.get(cp.name.toLowerCase());
            if (doc) {
                const isOptional = doc.optional !== undefined ? doc.optional : (cp.optional ?? false);
                merged.push({
                    name: cp.name,
                    type: doc.type && doc.type !== 'ANY' ? doc.type : cp.type,
                    defaultValue: cp.defaultValue || doc.defaultValue,
                    description: doc.description,
                    optional: isOptional
                });
                docMap.delete(cp.name.toLowerCase());
            }
            else {
                merged.push(cp);
            }
        }
        // Add remaining doc params that were not explicitly in params []
        for (const dp of docMap.values()) {
            merged.push(dp);
        }
        return merged;
    }
}
exports.SqfDocParser = SqfDocParser;
//# sourceMappingURL=docParser.js.map