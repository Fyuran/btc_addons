#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_strToCfg

Description:
    Restores a Cfg Path such as "bin\config.bin/cfgWaypoints/Default/Move" to configfile >> "cfgWaypoints" >> "Default" >> "Move"

Parameters:
    _cfgPath: STRING

Returns:
    CONFIG

Examples:
    (begin example)
        "bin\config.bin/cfgWaypoints/Default/Move"-> configfile >> "cfgWaypoints" >> "Default" >> "Move"
        ["bin\config.bin/cfgWaypoints/Default/Move"] call btc_toolchain_tools_fnc_strToCfg;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_cfgPath", "", [""]]
];

private _cleanPath = _cfgPath select [15]; // remove "bin\config.bin/"
private _tokens = _cleanPath splitString "/";


private _config = configFile;
{
    _config = _config >> _x; //appends config
} forEach _tokens;

if (!(isClass _config)) exitWith {
    [["%1: invalid config %2 passed", __FILE_NAME__, _cfgPath], REPORT, QCOMPONENT] call FUNC(debug);
    configNull
};

_config
