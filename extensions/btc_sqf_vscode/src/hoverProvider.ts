import * as vscode from 'vscode';
import { NativeCommandsManager } from './nativeCommands';
import { WorkspaceIndexer } from './workspaceIndexer';
import { CbaResolver } from './cbaResolver';
import { CommandSyntax, CustomFunctionInfo, NativeCommandInfo } from './types';
import { VariableTypeInferrer } from './variableInferrer';
import { SyntaxClassifier } from './syntaxClassifier';

const PREPROCESSOR_MACROS: Record<string, { syntax: string; description: string }> = {
    '__file_name__': {
        syntax: '(preprocessor macro) __FILE_NAME__ -> String',
        description: 'Built-in preprocessor macro replaced automatically with the name of the current file being processed, including its file extension (e.g. `"fnc_attributeLoad.sqf"`).\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__file__': {
        syntax: '(preprocessor macro) __FILE__ -> String',
        description: 'Built-in preprocessor macro replaced with the path and name of the current file being processed (e.g. `"userconfig\\file1.sqf"`).\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__file_short__': {
        syntax: '(preprocessor macro) __FILE_SHORT__ -> String',
        description: 'Built-in preprocessor macro replaced with the name of the current file being processed without its extension (e.g. `"file1"`).\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__line__': {
        syntax: '(preprocessor macro) __LINE__ -> Number',
        description: 'Built-in preprocessor macro replaced with the current line number where it is located.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__has_include': {
        syntax: '(preprocessor directive) __has_include("path") -> Boolean',
        description: 'Preprocessor directive check that returns `1` if the specified file exists and can be included, or `0` otherwise.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__counter__': {
        syntax: '(preprocessor macro) __COUNTER__ -> Number',
        description: 'Built-in preprocessor macro that expands to a sequential integer starting at `0` and incrementing by `1` every time it is evaluated.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__eval': {
        syntax: '(preprocessor macro) __EVAL(expression)',
        description: 'Config preprocessor macro used to evaluate an expression and substitute the result into configuration properties.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__exec': {
        syntax: '(preprocessor macro) __EXEC(statement)',
        description: 'Config preprocessor macro used to execute arbitrary script code within `parsingNamespace` during configuration parsing.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__date_str__': {
        syntax: '(preprocessor macro) __DATE_STR__ -> String',
        description: 'Built-in preprocessor macro returning the build date string.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__time__': {
        syntax: '(preprocessor macro) __TIME__ -> String',
        description: 'Built-in preprocessor macro returning the build time string.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    },
    '__timestamp_utc__': {
        syntax: '(preprocessor macro) __TIMESTAMP_UTC__ -> String',
        description: 'Built-in preprocessor macro returning the build UTC timestamp.\n\n[Arma 3 PreProcessor Commands Documentation](https://community.bistudio.com/wiki/PreProcessor_Commands)'
    }
};

const MAGIC_VARIABLES: Record<string, { syntax: string; description: string }> = {
    '_this': {
        syntax: '(magic variable) _this: Any',
        description: 'Contains the arguments passed to a script, function, event handler, or code block executed with `call`, `spawn`, or `execVM`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_this)'
    },
    '_x': {
        syntax: '(magic variable) _x: Any',
        description: 'Represents the current element in loops and iteration constructs such as `forEach`, `count`, `select`, `apply`, `findIf`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_x)'
    },
    '_y': {
        syntax: '(magic variable) _y: Any',
        description: 'Represents the current key in a `forEach` loop iterating over a HashMap (while `_x` represents the value).\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_y)'
    },
    '_foreachindex': {
        syntax: '(magic variable) _forEachIndex: Number',
        description: 'Contains the current zero-based iteration index in a `forEach` loop.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_forEachIndex)'
    },
    '_self': {
        syntax: '(magic variable) _self: HashMap',
        description: 'References the HashMap instance itself within a HashMap method call.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_self)'
    },
    '_exception': {
        syntax: '(magic variable) _exception: Any',
        description: 'Contains the exception object caught in a `catch` block after being thrown with `throw`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_exception)'
    },
    '_thisargs': {
        syntax: '(magic variable) _thisArgs: Any',
        description: 'Holds custom arguments passed when registering event handlers with `addEventHandler` / `addMPEventHandler` / `addUserActionEventHandler`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisArgs)'
    },
    '_thisevent': {
        syntax: '(magic variable) _thisEvent: String',
        description: 'Contains the name of the event currently being executed in an event handler.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisEvent)'
    },
    '_thiseventhandler': {
        syntax: '(magic variable) _thisEventHandler: Number',
        description: 'Contains the index / ID of the currently executing event handler, suitable for removing it with `removeEventHandler`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisEventHandler)'
    },
    '_thisscript': {
        syntax: '(magic variable) _thisScript: Script',
        description: 'Contains the script handle of the current script instance running via `execVM` or `spawn`.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_thisScript)'
    },
    '_fnc_scriptname': {
        syntax: '(magic variable) _fnc_scriptName: String',
        description: 'Contains the name of the function currently executing (defined when functions are compiled with the BIS Functions Framework).\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptName)'
    },
    '_fnc_scriptnameparent': {
        syntax: '(magic variable) _fnc_scriptNameParent: String',
        description: 'Contains the name of the caller function that invoked the current function.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptNameParent)'
    },
    '_fnc_scriptmap': {
        syntax: '(magic variable) _fnc_scriptMap: Array',
        description: 'Contains the call stack trace of function names leading to the current execution.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#_fnc_scriptMap)'
    },
    'this': {
        syntax: '(magic variable) this: Object',
        description: 'Special variable available in vehicle/unit init fields and trigger condition/activation statements referring to the entity itself.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#this)'
    },
    'thislist': {
        syntax: '(magic variable) thisList: Array',
        description: 'In trigger statements, contains the list of all entities currently inside the trigger area that meet the activation criteria.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#thisList)'
    },
    'thistrigger': {
        syntax: '(magic variable) thisTrigger: Object',
        description: 'In trigger statements, references the trigger object itself.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#thisTrigger)'
    },
    'thisactivator': {
        syntax: '(magic variable) thisActivator: Object',
        description: 'In trigger statements, references the entity that activated the trigger.\n\n[Magic Variables Documentation](https://community.bistudio.com/wiki/Magic_Variables#thisActivator)'
    }
};

export class SqfHoverProvider implements vscode.HoverProvider {
    constructor(
        private nativeCommands: NativeCommandsManager,
        private indexer: WorkspaceIndexer
    ) {}

    public provideHover(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.Hover> {
        // Do not parse or provide hovers inside comments, comment blocks, or strings
        const classified = SyntaxClassifier.getClassified(document);
        if (classified.isPositionInCommentOrString(position, document)) {
            return undefined;
        }

        const config = vscode.workspace.getConfiguration('btcSqf');
        const enableNative = config.get<boolean>('enableNativeHovers', true);
        const enableCba = config.get<boolean>('enableCbaHovers', true);
        const enableCallHover = config.get<boolean>('enableCallHover', true);
        const enableVariableHover = config.get<boolean>('enableVariableHover', true);

        const lineText = document.lineAt(position.line).text;
        const charIndex = position.character;

        // 1. Check if hovering over a CBA macro or custom function
        if (enableCba) {
            const macro = CbaResolver.findMacroAtPosition(lineText, charIndex, document.uri.fsPath);
            if (macro) {
                const funcInfo = this.indexer.findFunction(macro.component, macro.name, macro.fullName);
                if (funcInfo) {
                    const md = this.buildCustomFunctionHover(funcInfo, macro.type);
                    const range = new vscode.Range(
                        position.line,
                        macro.range.startChar,
                        position.line,
                        macro.range.endChar
                    );
                    return new vscode.Hover(md, range);
                }
            }
        }

        // 2. Check if hovering over the 'call' keyword
        if (enableCallHover) {
            const wordRange = document.getWordRangeAtPosition(position, /\bcall\b/i);
            if (wordRange) {
                const callHover = this.handleCallHover(lineText, position, document.uri.fsPath, wordRange);
                if (callHover) {
                    return callHover;
                }
            }
        }

        // 3. Check for word under cursor
        const wordRange = document.getWordRangeAtPosition(position, /[_a-zA-Z0-9]+/);
        if (!wordRange) {
            return undefined;
        }

        const word = document.getText(wordRange);

        // 4. Check if hovering over a built-in preprocessor macro (e.g. __FILE_NAME__, __FILE__, __LINE__)
        const preprocessorMacro = PREPROCESSOR_MACROS[word.toLowerCase()];
        if (preprocessorMacro) {
            const md = new vscode.MarkdownString();
            md.isTrusted = true;
            md.appendCodeblock(preprocessorMacro.syntax, 'sqf');
            md.appendMarkdown(preprocessorMacro.description);
            return new vscode.Hover(md, wordRange);
        }

        // 5. Check if hovering over a magic variable (e.g. _this, _x, _y, _forEachIndex, _self, this, etc.)
        const magicVar = MAGIC_VARIABLES[word.toLowerCase()];
        if (magicVar) {
            const md = new vscode.MarkdownString();
            md.isTrusted = true;
            md.appendCodeblock(magicVar.syntax, 'sqf');
            md.appendMarkdown(magicVar.description);
            return new vscode.Hover(md, wordRange);
        }

        // 6. Check if hovering over a local variable (e.g. _arr, _target)
        if (enableVariableHover && word.startsWith('_') && !word.startsWith('__')) {
            const variables = VariableTypeInferrer.inferDocumentVariables(document, this.nativeCommands, position.line, this.indexer);
            const varInfo = variables.get(word.toLowerCase());
            if (varInfo) {
                const md = new vscode.MarkdownString();
                md.isTrusted = true;
                const kind = varInfo.isParameter ? 'parameter' : 'local variable';
                md.appendCodeblock(`(${kind}) ${varInfo.name}: ${varInfo.type}`, 'sqf');
                md.appendMarkdown(`**Inferred Type:** \`${varInfo.type}\`  \n`);
                if (varInfo.isParameter) {
                    md.appendMarkdown(`*Function Parameter declared in header/params*\n`);
                } else {
                    md.appendMarkdown(`*Declared at Line ${varInfo.line + 1}:* \`${varInfo.declarationText}\`\n`);
                }
                return new vscode.Hover(md, wordRange);
            }
        }

        // 5. Check if word is a custom function name in workspace index
        if (enableCba) {
            const customFunc = this.indexer.findFunction(undefined, word, word);
            if (customFunc) {
                const md = this.buildCustomFunctionHover(customFunc, 'RAW_FUNC');
                return new vscode.Hover(md, wordRange);
            }
        }

        // 6. Check if word is a native Arma 3 command
        if (enableNative) {
            const nativeCmd = this.nativeCommands.getCommand(word);
            if (nativeCmd) {
                const md = this.buildNativeCommandHover(nativeCmd, document, position, lineText, wordRange);
                return new vscode.Hover(md, wordRange);
            }
        }

        // 7. Check if word is a CBA macro documentation (e.g. QUOTE, GVAR, EFUNC)
        const cbaMacro = this.nativeCommands.getCbaMacro(word);
        if (cbaMacro) {
            const md = new vscode.MarkdownString();
            md.appendCodeblock(cbaMacro.syntax, 'sqf');
            md.appendMarkdown(cbaMacro.description);
            return new vscode.Hover(md, wordRange);
        }

        return undefined;
    }

    private handleCallHover(
        lineText: string,
        position: vscode.Position,
        filePath: string,
        callWordRange?: vscode.Range
    ): vscode.Hover | undefined {
        const startOffset = callWordRange ? callWordRange.end.character : position.character;
        const afterCall = lineText.slice(startOffset);
        const match = afterCall.match(/^\s*(Q?(?:E?FUNC)\s*\(\s*[^)]+\)|[a-zA-Z0-9_]+_fnc_[a-zA-Z0-9_]+|[a-zA-Z0-9_]+)/i);

        if (match) {
            const targetToken = match[1];
            const targetPos = startOffset + match.index! + match[0].indexOf(targetToken);
            const macro = CbaResolver.findMacroAtPosition(lineText, targetPos, filePath);

            if (macro) {
                const funcInfo = this.indexer.findFunction(macro.component, macro.name, macro.fullName);
                if (funcInfo) {
                    const md = this.buildCustomFunctionHover(funcInfo, macro.type);
                    const hoverRange = callWordRange || new vscode.Range(position.line, position.character, position.line, position.character + 4);
                    return new vscode.Hover(md, hoverRange);
                }
            } else {
                const funcInfo = this.indexer.findFunction(undefined, undefined, targetToken) || this.indexer.getFunction(targetToken);
                if (funcInfo) {
                    const md = this.buildCustomFunctionHover(funcInfo, 'RAW_FUNC');
                    const hoverRange = callWordRange || new vscode.Range(position.line, position.character, position.line, position.character + 4);
                    return new vscode.Hover(md, hoverRange);
                }
            }
        }

        return undefined;
    }

    private buildCustomFunctionHover(info: CustomFunctionInfo, macroType: string): vscode.MarkdownString {
        const md = new vscode.MarkdownString();
        md.isTrusted = true;
        md.supportHtml = true;

        // Signature construction
        let paramSignature = '';
        if (info.parameters.length > 0) {
            paramSignature = info.parameters
                .map(p => `${p.name}${p.optional ? '?' : ''}: ${p.type}`)
                .join(', ');
        }

        const callFormat = paramSignature
            ? `[${paramSignature}] call ${macroType === 'EFUNC' ? `EFUNC(${info.component},${info.shortName})` : `FUNC(${info.shortName})`}`
            : `[] call FUNC(${info.shortName})`;

        md.appendCodeblock(callFormat, 'sqf');

        // Full function name and component
        md.appendMarkdown(`**Function:** \`${info.fullName}\`  \n`);
        md.appendMarkdown(`**Component:** \`${info.component}\` | **Prefix:** \`${info.prefix}\`  \n`);
        const relativePath = vscode.workspace.asRelativePath(info.filePath);
        md.appendMarkdown(`*Source:* [${relativePath}](file://${info.filePath})  \n\n`);

        // Description
        if (info.description) {
            md.appendMarkdown(`${info.description}\n\n`);
        }

        // Parameters
        if (info.parameters.length > 0) {
            md.appendMarkdown(`**Parameters:**\n\n`);
            for (const param of info.parameters) {
                const optStr = param.optional ? ` *(optional${param.defaultValue ? `, default: \`${param.defaultValue}\`` : ''})*` : '';
                const typeStr = param.type && param.type !== 'ANY' ? `\`${param.type}\`` : '`ANY`';
                const descStr = param.description ? ` — ${param.description}` : '';
                md.appendMarkdown(`- \`${param.name}\`: ${typeStr}${optStr}${descStr}\n`);
            }
            md.appendMarkdown(`\n`);
        } else {
            md.appendMarkdown(`**Parameters:** *None*\n\n`);
        }

        // Returns
        if (info.returns) {
            md.appendMarkdown(`**Returns:** \`${info.returns}\`\n\n`);
        }

        // Example
        if (info.example) {
            md.appendMarkdown(`**Example:**\n`);
            md.appendCodeblock(info.example, 'sqf');
        }

        if (info.author) {
            md.appendMarkdown(`*Author: ${info.author}*  \n`);
        }

        return md;
    }

    private buildNativeCommandHover(
        cmd: NativeCommandInfo,
        document: vscode.TextDocument,
        position: vscode.Position,
        lineText: string,
        wordRange: vscode.Range
    ): vscode.MarkdownString {
        const md = new vscode.MarkdownString();
        md.isTrusted = true;
        md.supportHtml = true;

        const syntaxes = cmd.syntaxes || [];
        const leftExpr = VariableTypeInferrer.extractLeftOperand(lineText, wordRange.start.character);
        const rightExpr = VariableTypeInferrer.extractRightOperand(lineText, wordRange.end.character);

        const variables = VariableTypeInferrer.inferDocumentVariables(document, this.nativeCommands, position.line, this.indexer);
        const inferredLeft = leftExpr ? VariableTypeInferrer.inferExpressionType(leftExpr, variables, this.nativeCommands, this.indexer, document.uri.fsPath) : undefined;
        const inferredRight = rightExpr ? VariableTypeInferrer.inferExpressionType(rightExpr, variables, this.nativeCommands, this.indexer, document.uri.fsPath) : undefined;

        // Determine which overload best matches the usage in this line
        let activeSyntax: CommandSyntax | undefined;
        let matchedStatusText = '';

        if (leftExpr && syntaxes.length > 0) {
            // Find matching binary overload
            activeSyntax = syntaxes.find(s => {
                if (s.callType !== 'binary') return false;
                const leftOk = !s.leftParam || VariableTypeInferrer.isArgumentCompatible(leftExpr, inferredLeft || 'Any', s.leftParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                const rightOk = !s.rightParam || VariableTypeInferrer.isArgumentCompatible(rightExpr, inferredRight || 'Any', s.rightParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                return leftOk && rightOk;
            }) || syntaxes.find(s => s.callType === 'binary');

            if (activeSyntax && activeSyntax.callType === 'binary') {
                const leftType = activeSyntax.leftParam?.type || 'Any';
                const rightType = activeSyntax.rightParam?.type || 'Any';
                const leftCheck = VariableTypeInferrer.checkArgument(leftExpr, inferredLeft || 'Any', leftType, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                const rightCheck = VariableTypeInferrer.checkArgument(rightExpr, inferredRight || 'Any', rightType, variables, this.nativeCommands, this.indexer, document.uri.fsPath);

                if (leftCheck.isValid && rightCheck.isValid) {
                    const leftDesc = (leftType.toLowerCase() === 'vector3d' || leftType.toLowerCase().startsWith('position3d'))
                        ? `\`${inferredLeft}\` ✓ *(Matches 3-element array of numbers [x, y, z])*`
                        : `\`${inferredLeft}\` ✓ *(Matches \`${leftType}\`)*`;
                    const rightDesc = (rightType.toLowerCase() === 'vector3d' || rightType.toLowerCase().startsWith('position3d'))
                        ? `\`${inferredRight}\` ✓ *(Matches 3-element array of numbers [x, y, z])*`
                        : `\`${inferredRight}\` ✓ *(Matches \`${rightType}\`)*`;

                    matchedStatusText = `> 💡 **Type Inspection:** *(Matched Overload: \`${activeSyntax.typedSignature}\`)*\n` +
                        `> - Left operand \`${leftExpr}\`: ${leftDesc}\n` +
                        (rightExpr ? `> - Right operand \`${rightExpr}\`: ${rightDesc}\n\n` : '\n');
                } else if (!leftCheck.isValid) {
                    matchedStatusText = `> ⚠️ **Type Mismatch:** Left operand \`${leftExpr}\` ${leftCheck.reason || `is \`${inferredLeft}\`, expected \`${leftType}\`.`}\n\n`;
                } else if (!rightCheck.isValid) {
                    matchedStatusText = `> ⚠️ **Type Mismatch:** Right operand \`${rightExpr}\` ${rightCheck.reason || `is \`${inferredRight}\`, expected \`${rightType}\`.`}\n\n`;
                }
            }
        } else if (!leftExpr && syntaxes.length > 0) {
            // Find matching unary overload
            activeSyntax = syntaxes.find(s => {
                if (s.callType !== 'unary') return false;
                return !s.rightParam || VariableTypeInferrer.isArgumentCompatible(rightExpr, inferredRight || 'Any', s.rightParam.type, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
            }) || syntaxes.find(s => s.callType === 'unary');

            if (activeSyntax && activeSyntax.callType === 'unary' && rightExpr) {
                const rightType = activeSyntax.rightParam?.type || 'Any';
                const rightCheck = VariableTypeInferrer.checkArgument(rightExpr, inferredRight || 'Any', rightType, variables, this.nativeCommands, this.indexer, document.uri.fsPath);
                if (rightCheck.isValid) {
                    const rightDesc = (rightType.toLowerCase() === 'vector3d' || rightType.toLowerCase().startsWith('position3d'))
                        ? `\`${inferredRight}\` ✓ *(Matches 3-element array of numbers [x, y, z])*`
                        : `\`${inferredRight}\` ✓ *(Matches \`${rightType}\`)*`;
                    matchedStatusText = `> 💡 **Type Inspection:** *(Matched Overload: \`${activeSyntax.typedSignature}\`)*\n` +
                        `> - Argument \`${rightExpr}\`: ${rightDesc}\n\n`;
                } else {
                    matchedStatusText = `> ⚠️ **Type Mismatch:** Argument \`${rightExpr}\` ${rightCheck.reason || `is \`${inferredRight}\`, expected \`${rightType}\`.`}\n\n`;
                }
            }
        }

        if (!activeSyntax && syntaxes.length > 0) {
            activeSyntax = syntaxes[0];
        }

        // 1. Signature
        if (activeSyntax && activeSyntax.typedSignature) {
            md.appendCodeblock(activeSyntax.typedSignature, 'sqf');
        } else {
            md.appendCodeblock(cmd.syntax, 'sqf');
        }

        // 2. Locality badges (AL / AG, EL / EG) and Version
        const localityBadges: string[] = [];
        if (cmd.argumentLocality && cmd.argumentLocality !== 'Unspecified') {
            const icon = cmd.argumentLocality === 'Global' ? '🌐 [AG]' : '🔒 [AL]';
            localityBadges.push(`${icon} **${cmd.argumentLocality.toUpperCase()} ARGUMENT**`);
        }
        if (cmd.effectLocality && cmd.effectLocality !== 'Unspecified') {
            const icon = cmd.effectLocality === 'Global' ? '🌐 [EG]' : '🔒 [EL]';
            localityBadges.push(`${icon} **${cmd.effectLocality.toUpperCase()} EFFECT**`);
        }
        if (cmd.argumentLocality === 'Unspecified' && cmd.effectLocality === 'Unspecified') {
            localityBadges.push('⚙️ **Local (In-Memory)**');
        }

        if (localityBadges.length > 0) {
            md.appendMarkdown(`**Locality:** ${localityBadges.join(' &nbsp;|&nbsp; ')}  \n`);
        }

        if (cmd.since) {
            md.appendMarkdown(`**Version:** ⚡ *${cmd.since}*  \n\n`);
        } else if (cmd.game) {
            md.appendMarkdown(`**Introduced in:** *${cmd.game}*  \n\n`);
        }

        // 3. Matched Overload & Type Inspection
        if (matchedStatusText) {
            md.appendMarkdown(matchedStatusText);
        }

        // 4. Description
        if (cmd.description) {
            md.appendMarkdown(`${cmd.description}\n\n`);
        }

        // 5. Parameter Breakdown for Active Overload
        if (activeSyntax && activeSyntax.params.length > 0) {
            md.appendMarkdown(`**Parameters:**\n\n`);
            for (const param of activeSyntax.params) {
                const optStr = param.optional ? ' *(optional)*' : '';
                const defStr = param.defaultValue ? ` *(default: \`${param.defaultValue}\`)*` : '';
                const descStr = param.description ? ` — ${param.description}` : '';
                md.appendMarkdown(`- \`${param.name}\`: \`${param.type}\`${optStr}${defStr}${descStr}\n`);
            }
            md.appendMarkdown('\n');
        }

        // 6. Return Value
        if (activeSyntax && activeSyntax.returnType && activeSyntax.returnType !== 'Nothing') {
            const retDesc = activeSyntax.returnDescription ? ` — ${activeSyntax.returnDescription}` : '';
            md.appendMarkdown(`**Returns:** \`${activeSyntax.returnType}\`${retDesc}\n\n`);
        }

        // 7. Alternative Overloads
        const otherOverloads = syntaxes.filter(s => s !== activeSyntax);
        if (otherOverloads.length > 0) {
            md.appendMarkdown(`**Alternative Overloads (${otherOverloads.length}):**\n\n`);
            for (const other of otherOverloads) {
                md.appendMarkdown(`- \`${other.signature}\` &rarr; \`${other.returnType}\`\n`);
            }
            md.appendMarkdown('\n');
        }

        // 8. Example
        if (cmd.example) {
            md.appendMarkdown(`**Example:**\n`);
            md.appendCodeblock(cmd.example, 'sqf');
        }

        // 9. Wiki Link
        md.appendMarkdown(`---\n`);
        md.appendMarkdown(`[Bohemia Interactive Community Wiki: **${cmd.name}**](${cmd.bikiUrl})\n`);

        return md;
    }
}
