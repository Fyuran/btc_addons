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
exports.NativeCommandsManager = void 0;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const cbaMacroDocs = {
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
class NativeCommandsManager {
    commands = new Map();
    constructor(extensionPath) {
        this.loadCommands(extensionPath);
    }
    loadCommands(extensionPath) {
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
        }
        catch (err) {
            console.error('[BTC SQF] Failed to load native commands dictionary:', err);
        }
    }
    getCommand(name) {
        return this.commands.get(name.toLowerCase());
    }
    getAllCommands() {
        return Array.from(this.commands.values());
    }
    getCbaMacro(name) {
        return cbaMacroDocs[name.toLowerCase()];
    }
    hasCommand(name) {
        return this.commands.has(name.toLowerCase());
    }
}
exports.NativeCommandsManager = NativeCommandsManager;
//# sourceMappingURL=nativeCommands.js.map