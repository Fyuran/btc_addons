#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_fillInventory

Description:
    Clears existing cargo and fills a supply crate/container with configured items,
    weapons, magazines, equipment, and backpacks.

Parameters:
    _supply: OBJECT - Supply crate or container object
    _inventory: ARRAY - Array of items in format [_class, _count]

Returns:
    BOOL - True if inventory was processed, false otherwise

Examples:
    (begin example)
        [_supply, [["FirstAidKit", 10], ["B_AssaultPack_blk", 2]]] call btc_toolchain_supply_fnc_fillInventory;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_supply", objNull, [objNull]],
    ["_inventory", [], [[]]]
];

if (isNull _supply) exitWith {
    [["%1: _supply is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    false
};

if (_inventory isEqualTo []) exitWith { false };

clearMagazineCargoGlobal _supply;
clearWeaponCargoGlobal _supply;
clearBackpackCargoGlobal _supply;
clearItemCargoGlobal _supply; // also removes vests and uniforms

private _backpackBase = configFile >> "CfgVehicles" >> "Bag_Base";
private _supplyClass = typeOf _supply;

_inventory apply {
    _x params [
        ["_class", "", [""]],
        ["_count", 1, [123]]
    ];

    if (
        (!isClass (configFile >> "CfgVehicles" >> _class)) &&
        {(!isClass (configFile >> "CfgWeapons" >> _class))} &&
        {(!isClass (configFile >> "CfgAmmo" >> _class))} &&
        {(!isClass (configFile >> "CfgMagazines" >> _class))}
    ) then {
        [["%1: invalid class %2", __FILE_NAME__, _class], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        continue;
    };

    if !([_supply, _class] call CBAFUNC(canAddItem)) then {
        [["%1: no inventory room for %2 in %3", __FILE_NAME__, _class, _supplyClass], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        continue;
    };

    private _probableBackpack = configFile >> "CfgVehicles" >> _class;
    private _inheritsFromBackpackbase = [_probableBackpack, _backpackBase] call CBAFUNC(inheritsFrom);
    if (_inheritsFromBackpackbase) then {
        _supply addBackpackCargoGlobal [_class, (_count) max 1];
    } else {
        _supply addItemCargoGlobal [_class, (_count) max 1]; // Works with items, weapons, magazines, equipment, and glasses
    };
};

true

