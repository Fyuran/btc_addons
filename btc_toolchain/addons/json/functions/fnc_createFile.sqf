#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_createFile

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_json_fnc_createFile;
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
