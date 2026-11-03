import * as fs from 'fs';
import * as path from 'path';
import { NativeCommandInfo } from './types';

const cbaMacroDocs: Record<string, { syntax: string; description: string }> = {
    func: {
        syntax: 'FUNC(functionName)',
        description: 'CBA Macro. Expands to `TRIPLES(PREFIX, COMPONENT, DOUBLES(fnc, functionName))`, resolving to `<prefix>_<component>_fnc_<functionName>`.'
    },
    efunc: {
        syntax: 'EFUNC(component, functionName)',
        description: 'CBA Macro. Expands to `TRIPLES(PREFIX, component, DOUBLES(fnc, functionName))`, calling a function from another component within the same addon prefix.'
    },
    qfunc: {
        syntax: 'QFUNC(functionName)',
        description: 'CBA Macro. Expands to `QUOTE(FUNC(functionName))`, returning the function name string: `"<prefix>_<component>_fnc_<functionName>"`.'
    },
    qefunc: {
        syntax: 'QEFUNC(component, functionName)',
        description: 'CBA Macro. Expands to `QUOTE(EFUNC(component, functionName))`, returning the external function name string.'
    },
    gvar: {
        syntax: 'GVAR(variableName)',
        description: 'CBA Macro. Expands to `TRIPLES(PREFIX, COMPONENT, variableName)`, resolving to `<prefix>_<component>_<variableName>`.'
    },
    egvar: {
        syntax: 'EGVAR(component, variableName)',
        description: 'CBA Macro. Expands to `TRIPLES(PREFIX, component, variableName)`, resolving to external component variable name.'
    },
    qgvar: {
        syntax: 'QGVAR(variableName)',
        description: 'CBA Macro. Expands to `QUOTE(GVAR(variableName))`, returning the variable name string.'
    },
    qegvar: {
        syntax: 'QEGVAR(component, variableName)',
        description: 'CBA Macro. Expands to `QUOTE(EGVAR(component, variableName))`, returning the external variable name string.'
    },
    quote: {
        syntax: 'QUOTE(expression)',
        description: 'CBA Macro. Stringifies the passed expression using the `#` preprocessor operator.'
    },
    prep: {
        syntax: 'PREP(functionName)',
        description: 'CBA Macro. Compiles `functions/fnc_<functionName>.sqf` and assigns it to `FUNC(<functionName>)`.'
    },
    prep_folder: {
        syntax: 'PREP_FOLDER(folderName, functionName)',
        description: 'HEMTT/CBA Macro. Compiles `functions/<folderName>/fnc_<functionName>.sqf` and assigns it to `FUNC(<folderName>_<functionName>)`.'
    }
};

export class NativeCommandsManager {
    private commands: Map<string, NativeCommandInfo> = new Map();

    constructor(extensionPath: string) {
        this.loadCommands(extensionPath);
    }

    private loadCommands(extensionPath: string) {
        try {
            const dataPath = path.join(extensionPath, 'data', 'commands.json');
            if (fs.existsSync(dataPath)) {
                let raw = fs.readFileSync(dataPath, 'utf-8');
                raw = raw.replace(/HashMapUnknown/g, 'HashMap');
                const parsed = JSON.parse(raw);
                for (const key of Object.keys(parsed)) {
                    this.commands.set(key.toLowerCase(), parsed[key]);
                }
            }
        } catch (err) {
            console.error('[BTC SQF] Failed to load native commands dictionary:', err);
        }
    }

    public getCommand(name: string): NativeCommandInfo | undefined {
        return this.commands.get(name.toLowerCase());
    }

    public getAllCommands(): NativeCommandInfo[] {
        return Array.from(this.commands.values());
    }

    public getCbaMacro(name: string): { syntax: string; description: string } | undefined {
        return cbaMacroDocs[name.toLowerCase()];
    }

    public hasCommand(name: string): boolean {
        return this.commands.has(name.toLowerCase());
    }
}
