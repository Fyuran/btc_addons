#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_getWeaponModes

Description:

Parameters:
    _weaponClass: STRING - Weapon classname in CfgWeapons

Returns:
    ARRAY

Examples:
    (begin example)
        // Retrieve weapon modes from weapon class
        private _modes = ["B_Plane_CAS_01_dynamicLoadout_F"] call btc_toolchain_tools_fnc_getWeaponModes;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_weaponClass", "", [""]]
];

if (_weaponClass isEqualTo "") exitWith {
    [["%1: _weaponClass is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _weapCfg = configFile >> "CfgWeapons" >> _weaponClass;
private _modes = getArray (_weapCfg >> "modes");
private _thisIndex = _modes findIf {_x isEqualTo "this"};
if (_thisIndex isNotEqualTo -1) then {
    _modes set [_thisIndex, _weaponClass];
};

_modes
