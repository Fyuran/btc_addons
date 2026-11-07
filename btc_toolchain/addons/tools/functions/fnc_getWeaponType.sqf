#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_getWeaponType

Description:
    Determines the category/type of a weapon ("cannon", "rocket", "missile", "bomb", or "other")
    based on cursor type, CfgWeapons class inheritance, and primary ammunition type.

Parameters:
    _weaponClass: STRING - Weapon classname in CfgWeapons

Returns:
    STRING - Category: "cannon", "rocket", "missile", "bomb", or "other"

Examples:
    (begin example)
        private _type = ["gatling_30mm"] call btc_toolchain_tools_fnc_getWeaponType; // "cannon"
        private _type = ["Missile_AGM_02_Plane_CAS_01_F"] call btc_toolchain_tools_fnc_getWeaponType; // "missile"
        private _type = ["Rocket_04_HE_Plane_CAS_01_F"] call btc_toolchain_tools_fnc_getWeaponType; // "rocket"
        private _type = ["Bomb_04_Plane_CAS_01_F"] call btc_toolchain_tools_fnc_getWeaponType; // "bomb"
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_weaponClass", "", [""]]
];

if (_weaponClass isEqualTo "") exitWith {"other"};

private _weapCfg = configFile >> "CfgWeapons" >> _weaponClass;
if (!isClass _weapCfg) exitWith {"other"};

if (_weaponClass isKindOf ["BombLauncher", configFile >> "CfgWeapons"] ||
    {_weaponClass isKindOf ["Mk82BombLauncher", configFile >> "CfgWeapons"]}) exitWith {"bomb"};
if (_weaponClass isKindOf ["MissileLauncher", configFile >> "CfgWeapons"]) exitWith {"missile"};
if (_weaponClass isKindOf ["RocketPods", configFile >> "CfgWeapons"]) exitWith {"rocket"};
if (_weaponClass isKindOf ["CannonCore", configFile >> "CfgWeapons"] ||
    {_weaponClass isKindOf ["MGunCore", configFile >> "CfgWeapons"]}) exitWith {"cannon"};

private _mags = getArray (_weapCfg >> "magazines");
if (_mags isNotEqualTo []) exitWith {
    private _ammo = getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo");
    if (_ammo isEqualTo "") exitWith {"other"};
    if (_ammo isKindOf ["BombCore", configFile >> "CfgAmmo"] ||
        {_ammo isKindOf ["LaserBombCore", configFile >> "CfgAmmo"]}) exitWith {"bomb"};
    if (_ammo isKindOf ["MissileBase", configFile >> "CfgAmmo"]) exitWith {"missile"};
    if (_ammo isKindOf ["RocketBase", configFile >> "CfgAmmo"]) exitWith {"rocket"};
    if (_ammo isKindOf ["BulletBase", configFile >> "CfgAmmo"]) exitWith {"cannon"};
    "other"
};

"other"
