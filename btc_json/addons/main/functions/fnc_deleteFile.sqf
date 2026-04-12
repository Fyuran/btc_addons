#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_deleteFile
Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_json_json_fnc_deleteFile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]]
];
if(_path isEqualTo "") exitWith {
    ["'path' property missing"] call BIS_fnc_error;
};

_request = createHashMapFromArray[
	["function", "deleteFile"],
	["path", _path]
];

_request call FUNC(callExtension)
