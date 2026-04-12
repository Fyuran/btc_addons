#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_retrieveList

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_json_fnc_retrieveList;
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
	["function", "retrieveList"],
	["path", _path]
];

_request call FUNC(callExtension)
