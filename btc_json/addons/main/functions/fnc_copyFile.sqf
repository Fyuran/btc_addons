#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_copyFile

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_json_json_fnc_copyFile;
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
	["function", "copyFile"],
	["path", _path],
	["newPath", _newPath]
];

_request call FUNC(callExtension)
