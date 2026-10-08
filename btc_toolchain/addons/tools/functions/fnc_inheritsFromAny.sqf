#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_inheritsFromAny

Description:
    Performs the config check to verify if passed class inherits from passed base classes

Parameters:
    _class: STRING or OBJECT
    _baseClasses: ARRAY of STRING
    _root: STRING

Returns:
    STRING

Examples:
    (begin example)
        private _inherits = ["B_Soldier_A_F", ["Land", "Air"]] call btc_toolchain_tools_fnc_inheritsFromAny;
        private _inherits = [cursorObject, ["Land", "Air"]] call btc_toolchain_tools_fnc_inheritsFromAny;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_class", "", ["", objNull]],
    ["_baseClasses", ["Air", "Land"], [[], ""]],
    ["_root", "CfgVehicles", [""]]
];

//Convert object to class string
if (_class isEqualType objNull) then {
    _class = typeOf _class;
};

if (_class isEqualTo "") exitWith {
    false;
};

//Convert single string to array of string
if (_baseClasses isEqualType "") then {
    _baseClasses = [_baseClasses];
};

if (!isClass (configFile >> _root)) exitWith {
    false;
};

private _cfgRoot = configFile >> _root;
private _classCfg = _cfgRoot >> _class;
if (!isClass _classCfg) exitWith {false};

(_baseClasses findIf {
    [_classCfg, _cfgRoot >> _x] call CBAFUNC(inheritsFrom);
}) isNotEqualTo -1
