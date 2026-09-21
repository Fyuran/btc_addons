#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_deleteFile
Description:
    Deletes JSON file in [PATH:STRING]

Parameters:
    _path: STRING

Returns:

Examples:
    (begin example)
        ["./armatojson/test.json"] call btc_json_json_fnc_deleteFile;
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
