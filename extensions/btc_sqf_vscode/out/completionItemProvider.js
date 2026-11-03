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
        const eventItems = this.getEventHandlerCompletions(document, classified, position, lineText, lineUntilCursor);
        if (eventItems) {
            return eventItems;
        }
        // If inside a string (and not an event handler argument), suppress completions
        if (classified.isInsideString(offset)) {
            return undefined;
        }
        const items = [];
        // 1. Inside FUNC(...) or QFUNC(...)
        // e.g. FUNC( or QFUNC( or FUNC(veh
        const funcMacroMatch = lineUntilCursor.match(/\b(Q?FUNC)\s*\(\s*([_a-zA-Z0-9]*)$/i);
        if (funcMacroMatch) {
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
        if (efuncFuncMatch) {
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
        if (efuncCompMatch) {
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
        if (callMatch) {
            const ctx = cbaResolver_1.CbaResolver.resolveContext(document.uri.fsPath);
            const compFunctions = this.indexer.getFunctionsByComponent(ctx.component);
            // Suggest FUNC(funcName) for current component
            for (const fn of compFunctions) {
                const item = new vscode.CompletionItem(`FUNC(${fn.shortName})`, vscode.CompletionItemKind.Function);
                item.detail = `[${this.formatParams(fn)}] call FUNC(${fn.shortName})`;
                item.documentation = this.buildDoc(fn);
                item.insertText = `FUNC(${fn.shortName})`;
                item.sortText = `0_${fn.shortName}`;
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
                    item.sortText = `1_${fn.component}_${fn.shortName}`;
                    items.push(item);
                }
            }
            // Macro call snippets
            const funcSnippet = new vscode.CompletionItem('FUNC(...)', vscode.CompletionItemKind.Snippet);
            funcSnippet.insertText = new vscode.SnippetString('FUNC(${1:functionName})');
            funcSnippet.detail = 'CBA FUNC macro call';
            funcSnippet.sortText = '2_0';
            items.push(funcSnippet);
            const efuncSnippet = new vscode.CompletionItem('EFUNC(...)', vscode.CompletionItemKind.Snippet);
            efuncSnippet.insertText = new vscode.SnippetString('EFUNC(${1:component}, ${2:functionName})');
            efuncSnippet.detail = 'CBA EFUNC macro call';
            efuncSnippet.sortText = '2_1';
            items.push(efuncSnippet);
            return items;
        }
        // 4. Local variables (when typing starting with '_')
        const wordMatch = lineUntilCursor.match(/([_a-zA-Z0-9]+)$/);
        const prefix = wordMatch ? wordMatch[1] : '';
        if (prefix.startsWith('_')) {
            const variables = variableInferrer_1.VariableTypeInferrer.inferDocumentVariables(document, this.nativeCommands, undefined, this.indexer);
            for (const v of variables.values()) {
                const item = new vscode.CompletionItem(v.name, vscode.CompletionItemKind.Variable);
                item.detail = `(local variable) ${v.name}: ${v.type}`;
                item.documentation = new vscode.MarkdownString(`Declared on line ${v.line + 1}:\n\`\`\`sqf\n${v.declarationText}\n\`\`\``);
                item.sortText = `0_${v.name}`;
                items.push(item);
            }
        }
        // 5. CBA Macro snippets
        this.addMacroSnippets(items);
        // 6. Native SQF commands
        if (this.nativeCommands) {
            const allCmds = this.nativeCommands.getAllCommands();
            for (const cmd of allCmds) {
                const item = new vscode.CompletionItem(cmd.name, vscode.CompletionItemKind.Function);
                item.detail = cmd.syntaxes && cmd.syntaxes.length > 0 ? cmd.syntaxes[0].typedSignature : cmd.name;
                item.documentation = new vscode.MarkdownString(cmd.description || '');
                item.sortText = `1_${cmd.name}`;
                items.push(item);
            }
        }
        return items;
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
    addMacroSnippets(items) {
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
            item.sortText = `2_${m.label}`;
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