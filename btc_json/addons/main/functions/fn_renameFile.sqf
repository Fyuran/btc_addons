#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_renameFile

Description:
    Renames JSON file in [PATH:STRING] to [NEWPATH:STRING].

Parameters:
    _path: STRING
    _newPath: STRING

Returns:

Examples:
    (begin example)
        ["./armatojson/test.json", "./armatojson/test_rename.json"] call btc_json_json_fnc_renameFile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]],
	["_newPath", "", [""]]
];
if(_path isEqualTo "") exitWith {
    ["'path' property missing"] call BIS_fnc_error;
};
if(_newPath isEqualTo "") exitWith {
    ["'newPath' property missing"] call BIS_fnc_error;
};

private _request = createHashMapFromArray[
	["function", "renameFile"],
	["path", _path],
	["newPath", _newPath]
];

_request call FUNC(callExtension)
