#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_deleteFile
Description:
    Deletes JSON file in [PATH:STRING]
Parameters:
    _path: STRING
Returns:

Examples:
    (begin example)
        ["./armatojson/test.json"] call btc_toolchain_json_fnc_deleteFile
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_path", "", [""]]
];
if(_path isEqualTo "") exitWith {
    [["%1: path property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_request = createHashMapFromArray[
	["function", "deleteFile"],
	["path", _path]
];

_request call FUNC(callExtension)
