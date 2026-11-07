#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_isCombatWeapon

Description:
    Checks if a weapon is a combat-oriented weapon, filtering out utility items
    such as vehicle horns, countermeasures (flares), fake weapons, and mounted
    laser designators.

Parameters:
    _weaponClass: STRING - Weapon classname in CfgWeapons

Returns:
    BOOLEAN - True if the weapon is a combat weapon, false if utility or invalid

Examples:
    (begin example)
        private _isCombat = ["gatling_30mm"] call btc_toolchain_tools_fnc_isCombatWeapon; // true
        private _isCombat = ["CMFlareLauncher"] call btc_toolchain_tools_fnc_isCombatWeapon; // false
        private _isCombat = ["TruckHorn"] call btc_toolchain_tools_fnc_isCombatWeapon; // false
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_weaponClass", "", [""]]
];

if (_weaponClass isEqualTo "") exitWith {false};

private _cfg = configFile >> "CfgWeapons" >> _weaponClass;
if (!isClass _cfg) exitWith {false};

!(
    _weaponClass isKindOf ["Horn", configFile >> "CfgWeapons"] ||
    {_weaponClass isKindOf ["CMFlareLauncher", configFile >> "CfgWeapons"]} ||
    {_weaponClass isKindOf ["FakeHorn", configFile >> "CfgWeapons"]} ||
    {_weaponClass isKindOf ["Pylon_DummyLauncher", configFile >> "CfgWeapons"]} ||
    {_weaponClass isKindOf ["FakeWeapon", configFile >> "CfgWeapons"]} ||
    {_weaponClass isKindOf ["Laserdesignator_mounted", configFile >> "CfgWeapons"]} ||
    {_weaponClass in ["CarHorn", "TruckHorn", "BikeHorn", "SportCarHorn", "CMFlareLauncher", "CMFlareLauncher_Triples", "CMFlareLauncher_Singles"]}
)
