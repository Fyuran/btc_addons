#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_copyFile

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_json_fnc_copyFile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]],
	["_newPath", "", [""]]
];
if(_path isEqualTo "") exitWith {
    [["%1: path property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_newPath isEqualTo "") exitWith {
    [["%1: newPath property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _request = createHashMapFromArray[
	["function", "copyFile"],
	["path", _path],
	["newPath", _newPath]
];

_request call FUNC(callExtension)
