#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_getAllConfigsOf

Description:
    Retrieves all classes matching or inheriting from _baseClass in _root that have scope == 2.

Parameters:
    _baseClass: STRING - Base classname to filter subclasses (optional, default: "All")
    _root: CONFIG - Root configuration path to search within (optional, default: configFile >> "CfgVehicles")

Returns:
    ARRAY - Array of matching config classes

Examples:
    (begin example)
        private _configs = ["Air"] call btc_toolchain_tools_fnc_getAllConfigsOf;
        private _configs = ["Car", configFile >> "CfgVehicles"] call btc_toolchain_tools_fnc_getAllConfigsOf;
        private _configs = ["Rifle", configFile >> "CfgWeapons"] call btc_toolchain_tools_fnc_getAllConfigsOf;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_baseClass", "All", [""]],
    ["_root", configFile >> "CfgVehicles", [configNull]]
];

if (!(isClass _root)) exitWith {
    [["%1: _root '%2' is not a valid class", __FILE_NAME__, configName _root], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

if (!(isClass (_root >> _baseClass))) exitWith {
    [["%1: '%2' is not a valid class of '%3'", __FILE_NAME__, _baseClass, configName _root], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

private _configs = format["(configName _x) isKindOf '%1' && {getNumber (_x >> 'scope') isEqualTo 2} && {getNumber (_x >> 'isUav') != 1}", _baseClass] configClasses _root;
if (_configs isEqualTo []) exitWith {
    [["%1: _configs with %2 as _baseClass and %3 as _root is empty", __FILE_NAME__, _baseClass, configName _root], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

_configs
