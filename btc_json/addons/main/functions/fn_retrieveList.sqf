#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_retrieveList

Description:
    Retrieves the list of JSON files recursively starting from [PATH:STRING].

Parameters:
    _path: STRING

Returns:

Examples:
    (begin example)
        ["."] call btc_json_json_fnc_retrieveList;
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
	["function", "retrieveList"],
	["path", _path]
];

_request call FUNC(callExtension)
