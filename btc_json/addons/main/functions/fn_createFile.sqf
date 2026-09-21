#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_createFile

Description:
    Generate a file by passing [PATH:STRING, DATA:ANY] as arguments, 
    will save whatever is in data, provided it's a json compatible format or a hashmap, to path

Parameters:
    _path: STRING
    _data: STRING/ANY

Returns:

Examples:
    (begin example)
        ["./armatojson/test.json", createHashMap] call btc_json_json_fnc_createFile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]],
	["_data", "", []]
];
if(_path isEqualTo "") exitWith {
    ["'path' property missing"] call BIS_fnc_error;
};
if(_path isEqualTo ".") exitWith {
    ["current path cannot be used as file path"] call BIS_fnc_error;
};
if(_path isEqualTo "./") exitWith {
    ["'path' property is incomplete"] call BIS_fnc_error;
};
if(_data isEqualTo "") exitWith {
    ["'data' property missing"] call BIS_fnc_error;
};

private _request = createHashMapFromArray[
	["function", "createFile"],
	["path", _path],
	["data", _data]
];

_request call FUNC(callExtension)
