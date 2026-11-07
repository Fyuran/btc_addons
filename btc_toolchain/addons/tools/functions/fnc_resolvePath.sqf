#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_resolvePath

Description:
    Resolves path based on if it has a trailing slash or semicolon

Parameters:
    _path: STRING or ARRAY

Returns:
    STRING

Examples:
    (begin example)
        ["\a3\dubbing_radio_f\Sfx\in2a.ogg"] call btc_toolchain_tools_fnc_resolvePath;
        ["radionoise1.ogg"] call btc_toolchain_tools_fnc_resolvePath;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_path", "", ["", []]]
];

if (_path isEqualType []) then {
    _path = selectRandom _path;
};
if (_path isEqualTo "") exitWith {""};
if ((_path select [0, 1]) isEqualTo "\" || {(_path select [1, 1]) isEqualTo ":"}) exitWith {
    _path
};

getMissionPath _path
