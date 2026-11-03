export interface CommandParam {
    name: string;
    type: string;
    description?: string;
    optional?: boolean;
    defaultValue?: string | null;
}

export interface CommandSyntax {
    callType: 'nular' | 'unary' | 'binary';
    leftParam?: CommandParam;
    rightParam?: CommandParam;
    params: CommandParam[];
    returnType: string;
    returnDescription?: string;
    signature: string;
    typedSignature: string;
}

export interface NativeCommandInfo {
    name: string;
    syntax: string;
    description: string;
    example?: string;
    game?: string;
    since?: string;                              // e.g. "Arma 3 v1.56"
    argumentLocality?: 'Local' | 'Global' | 'Unspecified'; // AL / AG
    effectLocality?: 'Local' | 'Global' | 'Unspecified';   // EL / EG
    callType?: 'nular' | 'unary' | 'binary';
    leftType?: string;
    rightType?: string;
    returnType?: string;
    syntaxes?: CommandSyntax[];
    bikiUrl: string;
}

export interface InferredVariable {
    name: string;
    type: string;
    line: number;
    declarationText: string;
    isParameter?: boolean;
    depth?: number;
}

export interface FunctionParam {
    name: string;
    type: string;
    defaultValue?: string;
    description?: string;
    optional?: boolean;
}

export interface CustomFunctionInfo {
    fullName: string;            // e.g. "btc_toolchain_cas_fnc_list_initVehicleData"
    shortName: string;           // e.g. "list_initVehicleData"
    component: string;           // e.g. "cas"
    prefix: string;              // e.g. "btc_toolchain"
    filePath: string;            // absolute path on disk
    description: string;
    parameters: FunctionParam[];
    returns: string;
    example?: string;
    author?: string;
}

export type MacroType = 'FUNC' | 'EFUNC' | 'QFUNC' | 'QEFUNC' | 'GVAR' | 'EGVAR' | 'QGVAR' | 'QEGVAR' | 'RAW_FUNC';

export interface ResolvedMacro {
    type: MacroType;
    prefix: string;
    component: string;
    name: string;
    fullName: string;
    range: {
        startChar: number;
        endChar: number;
    };
}
