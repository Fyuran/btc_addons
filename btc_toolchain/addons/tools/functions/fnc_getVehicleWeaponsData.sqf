#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_getVehicleWeaponsData

Description:
    Retrieves all weapons mounted on a vehicle class (including pilot weapons,
    turret weapons, and dynamic loadout pylons) from CfgVehicles.
    Utilizes BIS_fnc_allTurrets for hierarchical turret resolution.

Parameters:
    _class: STRING - Vehicle classname in CfgVehicles
    _filterNonCombat: BOOLEAN - Exclude utility weapons such as horns, countermeasures, and fake weapons (optional, default: true)

Returns:
    ARRAY of HASHMAP with keys:
        - "class": STRING (weapon classname)
        - "displayName": STRING (localized name)
        - "icon": STRING (icon texture path)
        - "modes": ARRAY of STRING ("FullAuto", "Burst", "Single")
        - "magazines": ARRAY of STRING (compatible magazines from config)
        - "muzzle": STRING ("cannon", "rocket", "missile", "bomb", "other")

Examples:
    (begin example)
        // Retrieve weapon classnames from vehicle class
        private _weapons = ["B_Plane_CAS_01_dynamicLoadout_F"] call btc_toolchain_tools_fnc_getVehicleWeaponsData;

        // Retrieve all weapons including flares/horns
        private _allWeapons = ["B_Plane_CAS_01_dynamicLoadout_F", false] call btc_toolchain_tools_fnc_getVehicleWeaponsData;

        // Retrieve detailed weapon information for UI combos or targeting
        private _detailedWeapons = ["B_Plane_CAS_01_dynamicLoadout_F", true] call btc_toolchain_tools_fnc_getVehicleWeaponsData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_class", "", [""]],
    ["_filterNonCombat", true, [true]]
];

private _vehConfig = configFile >> "CfgVehicles" >> _class;
if (!isClass _vehConfig) exitWith {
    [["%1: invalid class '%2' in CfgVehicles", __FILE_NAME__, _class], REPORT, QCOMPONENT] call FUNC(debug);
    []
};

private _weapons = [];
_weapons append getArray (_vehConfig >> "weapons");
([_class, true] call BIS_fnc_allTurrets) apply {
    private _turretCfg = [_class, _x] call BIS_fnc_turretConfig;
    private _weaps = getArray (_turretCfg >> "weapons");
    _weapons append _weaps;
};

private _pylonsConfig = _vehConfig >> "Components" >> "TransportPylonsComponent" >> "Pylons";
if (isClass _pylonsConfig) then {
    {
        private _pylonWeap = getText (configFile >> "CfgMagazines" >> getText (_x >> "attachment") >> "pylonWeapon");
        if (_pylonWeap isNotEqualTo "") then {
            _weapons pushBackUnique _pylonWeap;
        };
    } forEach (configProperties [_pylonsConfig, "isClass _x", true]);
};

if (_filterNonCombat) then {
    _weapons = _weapons select { [_x] call FUNC(isCombatWeapon) };
};

// Detailed output mode: enrich with weapon metadata
private _result = [];

_weapons apply {
    private _weaponClass = _x;
    private _weapCfg = configFile >> "CfgWeapons" >> _weaponClass;
    private _displayName = getText (_weapCfg >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _weaponClass; };
    private _icon = getText (_weapCfg >> "picture");
    if (_icon isEqualTo "") then { _icon = getText (_weapCfg >> "icon"); };

    private _modes = getArray (_weapCfg >> "modes");
    // If modes[] in config for the weapon says {"this"}, 
    // then the same classname as for the weapon 
    // should be used as firemode param. https://community.bistudio.com/wiki/forceWeaponFire
    private _thisIndex = _modes findIf {_x isEqualTo "this"};
    if (_thisIndex isNotEqualTo -1) then {
        _modes set [_thisIndex, _weaponClass];
    };

    
    _result pushBack (createHashMapFromArray [
        ["class", _weaponClass],
        ["displayName", _displayName],
        ["icon", _icon],
        ["modes", _modes],
        ["magazines", getArray (_weapCfg >> "magazines")],
        ["muzzle", [_weaponClass] call FUNC(getWeaponType)]
    ]);
};

_result
