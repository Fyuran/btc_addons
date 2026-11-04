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
exports.SqfCompletionItemProvider = void 0;
const vscode = __importStar(require("vscode"));
const cbaResolver_1 = require("./cbaResolver");
const syntaxClassifier_1 = require("./syntaxClassifier");
const variableInferrer_1 = require("./variableInferrer");
const eventData_1 = require("./eventData");
const MAGIC_VARIABLES = [
    {
        name: '_this',
        syntax: '(magic variable) _this: Any',
        description: 'Contains the arguments passed to a script, function, event handler, or code block executed with `call`, `spawn`, or `execVM`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_this)'
    },
    {
        name: '_x',
        syntax: '(magic variable) _x: Any',
        description: 'Represents the current element in loops and iteration constructs such as `forEach`, `count`, `select`, `apply`, `findIf`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_x)'
    },
    {
        name: '_y',
        syntax: '(magic variable) _y: Any',
        description: 'Represents the current key in a `forEach` loop iterating over a HashMap (while `_x` represents the value).\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_y)'
    },
    {
        name: '_forEachIndex',
        syntax: '(magic variable) _forEachIndex: Number',
        description: 'Contains the current zero-based iteration index in a `forEach` loop.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_forEachIndex)'
    },
    {
        name: '_self',
        syntax: '(magic variable) _self: HashMap',
        description: 'References the HashMap instance itself within a HashMap method call.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_self)'
    },
    {
        name: '_exception',
        syntax: '(magic variable) _exception: Any',
        description: 'Contains the exception object caught in a `catch` block after being thrown with `throw`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_exception)'
    },
    {
        name: '_thisArgs',
        syntax: '(magic variable) _thisArgs: Any',
        description: 'Holds custom arguments passed when registering event handlers with `addEventHandler` / `addMPEventHandler` / `addUserActionEventHandler`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisArgs)'
    },
    {
        name: '_thisEvent',
        syntax: '(magic variable) _thisEvent: String',
        description: 'Contains the name of the event currently being executed in an event handler.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisEvent)'
    },
    {
        name: '_thisEventHandler',
        syntax: '(magic variable) _thisEventHandler: Number',
        description: 'Contains the index / ID of the currently executing event handler, suitable for removing it with `removeEventHandler`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisEventHandler)'
    },
    {
        name: '_thisScript',
        syntax: '(magic variable) _thisScript: Script',
        description: 'Contains the script handle of the current script instance running via `execVM` or `spawn`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisScript)'
    },
    {
        name: '_fnc_scriptName',
        syntax: '(magic variable) _fnc_scriptName: String',
        description: 'Contains the name of the function currently executing (defined when functions are compiled with the BIS Functions Framework).\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptName)'
    },
    {
        name: '_fnc_scriptNameParent',
        syntax: '(magic variable) _fnc_scriptNameParent: String',
        description: 'Contains the name of the caller function that invoked the current function.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptNameParent)'
    },
    {
        name: '_fnc_scriptMap',
        syntax: '(magic variable) _fnc_scriptMap: Array',
        description: 'Contains the call stack trace of function names leading to the current execution.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptMap)'
    }
];
class SqfCompletionItemProvider {
    indexer;
    nativeCommands;
    static ARRAY_EVENT_REGEX = /\b(addEventHandler|addMPEventHandler|removeEventHandler|removeMPEventHandler|ctrlAddEventHandler|ctrlRemoveEventHandler|ctrlSetEventHandler|displayAddEventHandler|displayRemoveEventHandler|displaySetEventHandler|addMissionEventHandler|removeMissionEventHandler)\s*\[\s*(["']?)([a-zA-Z0-9_]*)$/i;
    static STRING_EVENT_REGEX = /\b(removeAllEventHandlers|removeAllMPEventHandlers|ctrlRemoveAllEventHandlers|displayRemoveAllEventHandlers|removeAllMissionEventHandlers)\s+(["']?)([a-zA-Z0-9_]*)$/i;
    constructor(indexer, nativeCommands) {
        this.indexer = indexer;
        this.nativeCommands = nativeCommands;
    }
    provideCompletionItems(document, position, token, context) {
        // Forbid completion hints when typing a comma
        if (context.triggerCharacter === ',') {
            return undefined;
        }
        const config = vscode.workspace.getConfiguration('btcSqf');
        if (!config.get('enableCompletions', true)) {
            return undefined;
        }
        const enableNative = config.get('enableNativeCompletions', true);
        const enableCba = config.get('enableCbaCompletions', true);
        const enableVars = config.get('enableVariableCompletions', true);
        const enableSnippets = config.get('enableMacroSnippets', true);
        const classified = syntaxClassifier_1.SyntaxClassifier.getClassified(document);
        const offset = document.offsetAt(position);
        // Never provide completions inside comments
        if (classified.isInsideComment(offset) || (offset > 0 && classified.isInsideComment(offset - 1) && document.lineAt(position.line).text.trimStart().startsWith('//'))) {
            return undefined;
        }
        const lineText = document.lineAt(position.line).text;
        const lineMaskedCommentsOnly = classified.getLineMaskedCommentsOnly(position.line);
        const lineUntilCursor = lineMaskedCommentsOnly.slice(0, position.character);
        // Check for Event Handler autocompletion (addEventHandler, ctrlAddEventHandler, etc.)
        if (enableNative) {
            const eventItems = this.getEventHandlerCompletions(document, classified, position, lineText, lineUntilCursor);
            if (eventItems) {
                return eventItems;
            }
        }
        // Check if inside private ["_..."] or params ["_..."]
        const privateOrParamsMatch = lineUntilCursor.match(/\b(?:private|params)\s*\[[^\]]*?(["'])(_[a-zA-Z0-9_]*)$/i);
        const isInsidePrivateOrParams = !!privateOrParamsMatch;
        // If inside a string (and not an event handler argument or private/params declaration), suppress completions
        if (!isInsidePrivateOrParams && classified.isInsideString(offset)) {
            return undefined;
        }
        const items = [];
        // 1. Inside FUNC(...) or QFUNC(...)
        // e.g. FUNC( or QFUNC( or FUNC(veh
        const funcMacroMatch = lineUntilCursor.match(/\b(Q?FUNC)\s*\(\s*([_a-zA-Z0-9]*)$/i);
        if (enableCba && funcMacroMatch) {
            const macroType = funcMacroMatch[1].toUpperCase();
            const ctx = cbaResolver_1.CbaResolver.resolveContext(document.uri.fsPath);
            const compFunctions = this.indexer.getFunctionsByComponent(ctx.component);
            // Add current component functions first with high priority
            for (const fn of compFunctions) {
                items.push(this.createFunctionCompletionItem(fn, macroType, true));
            }
            // Also provide functions from other components sorted lower
            const allFunctions = this.indexer.getAllFunctions();
            for (const fn of allFunctions) {
                if (fn.component.toLowerCase() !== ctx.component.toLowerCase()) {
                    items.push(this.createFunctionCompletionItem(fn, macroType, false));
                }
            }
            return items;
        }
        // 2. Inside EFUNC(...) or QEFUNC(...)
        // Case 2A: Inside second parameter (function name): EFUNC(comp, or EFUNC(comp, veh
        const efuncFuncMatch = lineUntilCursor.match(/\b(Q?EFUNC)\s*\(\s*([_a-zA-Z0-9]+)\s*,\s*([_a-zA-Z0-9]*)$/i);
        if (enableCba && efuncFuncMatch) {
            const macroType = efuncFuncMatch[1].toUpperCase();
            const targetComp = efuncFuncMatch[2];
            const compFunctions = this.indexer.getFunctionsByComponent(targetComp);
            for (const fn of compFunctions) {
                items.push(this.createFunctionCompletionItem(fn, macroType, true, targetComp));
            }
            return items;
        }
        // Case 2B: Inside first parameter (component name): EFUNC( or EFUNC(cas
        const efuncCompMatch = lineUntilCursor.match(/\b(Q?E(?:FUNC|GVAR))\s*\(\s*([_a-zA-Z0-9]*)$/i);
        if (enableCba && efuncCompMatch) {
            const components = this.indexer.getAllComponents();
            for (const comp of components) {
                const item = new vscode.CompletionItem(comp, vscode.CompletionItemKind.Module);
                item.detail = `(component) ${comp}`;
                item.sortText = `0_${comp}`;
                items.push(item);
            }
            return items;
        }
        // 3. Right after 'call ' keyword
        // e.g. "call " or "call FUNC"
        const callMatch = lineUntilCursor.match(/\bcall\s+([_a-zA-Z0-9]*)$/i);
        if (callMatch && !callMatch[1].startsWith('_')) {
            if (enableCba) {
                const ctx = cbaResolver_1.CbaResolver.resolveContext(document.uri.fsPath);
                const compFunctions = this.indexer.getFunctionsByComponent(ctx.component);
                // Suggest FUNC(funcName) for current component
                for (const fn of compFunctions) {
                    const item = new vscode.CompletionItem(`FUNC(${fn.shortName})`, vscode.CompletionItemKind.Function);
                    item.detail = `[${this.formatParams(fn)}] call FUNC(${fn.shortName})`;
                    item.documentation = this.buildDoc(fn);
                    item.insertText = `FUNC(${fn.shortName})`;
                    item.sortText = `10_${fn.shortName}`;
                    items.push(item);
                }
                // Suggest EFUNC(comp, funcName) for other components
                const allFunctions = this.indexer.getAllFunctions();
                for (const fn of allFunctions) {
                    if (fn.component.toLowerCase() !== ctx.component.toLowerCase()) {
                        const item = new vscode.CompletionItem(`EFUNC(${fn.component}, ${fn.shortName})`, vscode.CompletionItemKind.Function);
                        item.detail = `[${this.formatParams(fn)}] call EFUNC(${fn.component}, ${fn.shortName})`;
                        item.documentation = this.buildDoc(fn);
                        item.insertText = `EFUNC(${fn.component}, ${fn.shortName})`;
                        item.sortText = `11_${fn.component}_${fn.shortName}`;
                        items.push(item);
                    }
                }
                if (enableSnippets) {
                    // Macro call snippets
                    const funcSnippet = new vscode.CompletionItem('FUNC(...)', vscode.CompletionItemKind.Snippet);
                    funcSnippet.insertText = new vscode.SnippetString('FUNC(${1:functionName})');
                    funcSnippet.detail = 'CBA FUNC macro call';
                    funcSnippet.sortText = '20_0';
                    items.push(funcSnippet);
                    const efuncSnippet = new vscode.CompletionItem('EFUNC(...)', vscode.CompletionItemKind.Snippet);
                    efuncSnippet.insertText = new vscode.SnippetString('EFUNC(${1:component}, ${2:functionName})');
                    efuncSnippet.detail = 'CBA EFUNC macro call';
                    efuncSnippet.sortText = '20_1';
                    items.push(efuncSnippet);
                }
            }
            // Also include local & magic variables (e.g. call _fnc) prioritized at 00_
            if (enableVars) {
                this.addVariableCompletions(items, document, classified);
            }
            return new vscode.CompletionList(items, true);
        }
        // 4. Local variables, macros, and native commands
        const wordMatch = lineUntilCursor.match(/([_a-zA-Z0-9]+)$/);
        const prefix = wordMatch ? wordMatch[1] : '';
        const isUnderscorePrefix = prefix.startsWith('_');
        // Variables: always included and prioritized at the top (00_, 01_, 02_)
        if (enableVars) {
            this.addVariableCompletions(items, document, classified);
        }
        // 5. CBA Macro snippets
        if (enableSnippets && enableCba) {
            this.addMacroSnippets(items, isUnderscorePrefix);
        }
        // 6. Native SQF commands
        if (enableNative && this.nativeCommands) {
            const allCmds = this.nativeCommands.getAllCommands();
            for (const cmd of allCmds) {
                const lower = cmd.name.toLowerCase();
                if (isUnderscorePrefix) {
                    // When the word starts with '_', only suggest commands containing '_' and sort them below variables
                    if (lower.includes('_')) {
                        const item = new vscode.CompletionItem(cmd.name, vscode.CompletionItemKind.Function);
                        item.detail = cmd.syntaxes && cmd.syntaxes.length > 0 ? cmd.syntaxes[0].typedSignature : cmd.name;
                        item.documentation = new vscode.MarkdownString(cmd.description || '');
                        item.sortText = `90_${lower}`;
                        items.push(item);
                    }
                }
                else {
                    const item = new vscode.CompletionItem(cmd.name, vscode.CompletionItemKind.Function);
                    item.detail = cmd.syntaxes && cmd.syntaxes.length > 0 ? cmd.syntaxes[0].typedSignature : cmd.name;
                    item.documentation = new vscode.MarkdownString(cmd.description || '');
                    item.sortText = `10_${lower}`;
                    items.push(item);
                }
            }
        }
        return new vscode.CompletionList(items, true);
    }
    createFunctionCompletionItem(fn, macroType, isCurrentComp, targetComp) {
        const item = new vscode.CompletionItem(fn.shortName, vscode.CompletionItemKind.Function);
        const comp = targetComp || fn.component;
        const callSig = macroType.includes('EFUNC')
            ? `EFUNC(${comp}, ${fn.shortName})`
            : `FUNC(${fn.shortName})`;
        item.detail = `(${comp}) [${this.formatParams(fn)}] call ${callSig}`;
        item.documentation = this.buildDoc(fn);
        item.insertText = fn.shortName;
        item.sortText = isCurrentComp ? `0_${fn.shortName}` : `1_${comp}_${fn.shortName}`;
        return item;
    }
    formatParams(fn) {
        if (!fn.parameters || fn.parameters.length === 0)
            return '';
        return fn.parameters.map(p => `${p.name}${p.optional ? '?' : ''}: ${p.type}`).join(', ');
    }
    buildDoc(fn) {
        const md = new vscode.MarkdownString();
        md.isTrusted = true;
        md.appendMarkdown(`### \`${fn.fullName}\`\n\n`);
        if (fn.description) {
            md.appendMarkdown(`${fn.description}\n\n`);
        }
        if (fn.parameters && fn.parameters.length > 0) {
            md.appendMarkdown(`**Parameters:**\n`);
            for (const p of fn.parameters) {
                const opt = p.optional ? ' *(optional)*' : '';
                const def = p.defaultValue ? ` (default: \`${p.defaultValue}\`)` : '';
                const desc = p.description ? ` - ${p.description}` : '';
                md.appendMarkdown(`- \`${p.name}\` (\`${p.type}\`)${opt}${def}${desc}\n`);
            }
            md.appendMarkdown(`\n`);
        }
        if (fn.returns) {
            md.appendMarkdown(`**Returns:** \`${fn.returns}\`\n\n`);
        }
        if (fn.example) {
            md.appendMarkdown(`**Example:**\n\`\`\`sqf\n${fn.example}\n\`\`\`\n`);
        }
        return md;
    }
    addVariableCompletions(items, document, classified) {
        const seenVars = new Set();
        // 4A. Inferred variables in document (params, assignments, for loops)
        try {
            const variables = variableInferrer_1.VariableTypeInferrer.inferDocumentVariables(document, this.nativeCommands, undefined, this.indexer);
            for (const v of variables.values()) {
                const lower = v.name.toLowerCase();
                seenVars.add(lower);
                const item = new vscode.CompletionItem(v.name, vscode.CompletionItemKind.Variable);
                item.detail = `(local variable) ${v.name}: ${v.type}`;
                item.documentation = new vscode.MarkdownString(`Declared on line ${v.line + 1}:\n\`\`\`sqf\n${v.declarationText}\n\`\`\``);
                item.sortText = `00_${lower}`;
                items.push(item);
            }
        }
        catch {
            // In case inference encounters unexpected draft syntax, continue with magic and document vars
        }
        // 4B. Magic variables (_this, _x, _y, _forEachIndex, _self, etc.)
        for (const mv of MAGIC_VARIABLES) {
            const lower = mv.name.toLowerCase();
            if (!seenVars.has(lower)) {
                seenVars.add(lower);
                const item = new vscode.CompletionItem(mv.name, vscode.CompletionItemKind.Variable);
                item.detail = mv.syntax;
                item.documentation = new vscode.MarkdownString(mv.description);
                item.sortText = `01_${lower}`;
                items.push(item);
            }
        }
        // 4C. Any other local variable names present in the document
        // (e.g. declared via private ["_var"], loop counters, or referenced in code)
        const docVarMatches = classified.maskedComments.match(/\b(_[a-zA-Z0-9_]+)\b/g);
        if (docVarMatches) {
            for (const varName of docVarMatches) {
                if (varName.startsWith('__'))
                    continue; // Skip __FILE__, __LINE__, etc.
                const lower = varName.toLowerCase();
                if (!seenVars.has(lower)) {
                    seenVars.add(lower);
                    const item = new vscode.CompletionItem(varName, vscode.CompletionItemKind.Variable);
                    item.detail = `(local variable) ${varName}: Any`;
                    item.documentation = new vscode.MarkdownString(`Local variable referenced in this document.`);
                    item.sortText = `02_${lower}`;
                    items.push(item);
                }
            }
        }
    }
    addMacroSnippets(items, isUnderscorePrefix = false) {
        const macros = [
            { label: 'FUNC(...)', snippet: 'FUNC(${1:functionName})', detail: 'CBA component function macro' },
            { label: 'EFUNC(...)', snippet: 'EFUNC(${1:component}, ${2:functionName})', detail: 'CBA external component function macro' },
            { label: 'QFUNC(...)', snippet: 'QFUNC(${1:functionName})', detail: 'Quoted CBA component function macro' },
            { label: 'QEFUNC(...)', snippet: 'QEFUNC(${1:component}, ${2:functionName})', detail: 'Quoted CBA external component function macro' },
            { label: 'GVAR(...)', snippet: 'GVAR(${1:variableName})', detail: 'CBA component global variable macro' },
            { label: 'QGVAR(...)', snippet: 'QGVAR(${1:variableName})', detail: 'Quoted CBA component global variable macro' },
            { label: 'EGVAR(...)', snippet: 'EGVAR(${1:component}, ${2:variableName})', detail: 'CBA external component global variable macro' },
            { label: 'QEGVAR(...)', snippet: 'QEGVAR(${1:component}, ${2:variableName})', detail: 'Quoted CBA external component global variable macro' },
            { label: 'QUOTE(...)', snippet: 'QUOTE(${1:content})', detail: 'CBA stringify macro' },
            { label: 'DOUBLES(...)', snippet: 'DOUBLES(${1:var1},${2:var2})', detail: 'CBA concatenate two identifiers' },
            { label: 'TRIPLES(...)', snippet: 'TRIPLES(${1:var1},${2:var2},${3:var3})', detail: 'CBA concatenate three identifiers' },
            { label: 'PARAMS_1(...)', snippet: 'PARAMS_1(${1:var})', detail: 'CBA params macro' },
            { label: 'PREP(...)', snippet: 'PREP(${1:functionName});', detail: 'CBA XEH_PREP compilation macro' },
            { label: 'PREP_FOLDER(...)', snippet: 'PREP_FOLDER(${1:folder},${2:functionName});', detail: 'HEMTT/CBA subfolder compilation macro' }
        ];
        for (const m of macros) {
            const item = new vscode.CompletionItem(m.label, vscode.CompletionItemKind.Snippet);
            item.insertText = new vscode.SnippetString(m.snippet);
            item.detail = m.detail;
            item.sortText = isUnderscorePrefix ? `99_${m.label}` : `20_${m.label}`;
            items.push(item);
        }
    }
    getEventHandlerCompletions(document, classified, position, lineText, lineUntilCursor) {
        let match = lineUntilCursor.match(SqfCompletionItemProvider.ARRAY_EVENT_REGEX);
        let commandName = '';
        let quoteChar = '';
        let prefix = '';
        if (match) {
            commandName = match[1];
            quoteChar = match[2];
            prefix = match[3];
        }
        else {
            const strMatch = lineUntilCursor.match(SqfCompletionItemProvider.STRING_EVENT_REGEX);
            if (strMatch) {
                commandName = strMatch[1];
                quoteChar = strMatch[2];
                prefix = strMatch[3];
            }
            else {
                // Multi-line scan: check up to 5 preceding lines if current line only has whitespace, quote and prefix
                const prefixMatch = lineUntilCursor.match(/^\s*(["']?)([a-zA-Z0-9_]*)$/);
                if (prefixMatch) {
                    let accumulated = lineUntilCursor;
                    for (let l = position.line - 1; l >= Math.max(0, position.line - 5); l--) {
                        const prevLine = classified.getLineMaskedCommentsOnly(l);
                        accumulated = prevLine + '\n' + accumulated;
                        if (prevLine.includes('[')) {
                            const multiMatch = accumulated.match(SqfCompletionItemProvider.ARRAY_EVENT_REGEX);
                            if (multiMatch) {
                                commandName = multiMatch[1];
                                quoteChar = prefixMatch[1];
                                prefix = prefixMatch[2];
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (!commandName) {
            return undefined;
        }
        const eventData = (0, eventData_1.getEventsForCommand)(commandName);
        if (!eventData) {
            return undefined;
        }
        const lineAfterCursor = lineText.slice(position.character);
        const hasClosingQuote = quoteChar !== '' && lineAfterCursor.startsWith(quoteChar);
        const replaceStartChar = position.character - prefix.length;
        const replaceEndChar = hasClosingQuote ? position.character + 1 : position.character;
        const replaceRange = new vscode.Range(new vscode.Position(position.line, replaceStartChar), new vscode.Position(position.line, replaceEndChar));
        const items = [];
        for (const evt of eventData.events) {
            const item = new vscode.CompletionItem(evt.name, vscode.CompletionItemKind.Event);
            item.detail = `(${eventData.categoryName})`;
            const doc = new vscode.MarkdownString();
            doc.isTrusted = true;
            doc.appendMarkdown(`### \`${evt.name}\`\n\n`);
            doc.appendMarkdown(`${evt.description}\n\n`);
            doc.appendCodeblock(evt.params, 'sqf');
            item.documentation = doc;
            let textToInsert = evt.name;
            if (quoteChar === '') {
                textToInsert = `"${evt.name}"`;
            }
            else {
                textToInsert = `${evt.name}${quoteChar}`;
            }
            item.insertText = textToInsert;
            item.range = replaceRange;
            item.sortText = `0_${evt.name}`;
            items.push(item);
        }
        return items;
    }
}
exports.SqfCompletionItemProvider = SqfCompletionItemProvider;
//# sourceMappingURL=completionItemProvider.js.map