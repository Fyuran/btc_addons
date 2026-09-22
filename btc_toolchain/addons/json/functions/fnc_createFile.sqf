#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_createFile

Description:
    Generate a file by passing [PATH:STRING, DATA:ANY] as arguments, 
    will save whatever is in data, provided it's a json compatible format or a hashmap, to path
Parameters:
    _path: STRING
    _data: STRING
Returns:

Examples:
    (begin example)
        ["./armatojson/test.json", createHashMap] call btc_toolchain_json_fnc_createFile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]],
	["_data", "", []]
];
if(_path isEqualTo "") exitWith {
    [["%1: path property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_path isEqualTo ".") exitWith {
    [["%1: current path cannot be used as a path", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_path isEqualTo "./") exitWith {
    [["%1: no filename for path found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_data isEqualTo "") exitWith {
    [["%1: data property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _request = createHashMapFromArray[
	["function", "createFile"],
	["path", _path],
	["data", _data]
];

_request call FUNC(callExtension)
