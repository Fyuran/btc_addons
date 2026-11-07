#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2OnAdjust

Description:
    Callback invoked by GUI list arrow adjust to update supply item quantity.

Parameters:
    _uid: STRING - Container UID
    _class: STRING - Item class name
    _newAmount: NUMBER - New quantity

Returns:
    NOTHING

Examples:
    (begin example)
        ["uid_123", "FirstAidKit", 5] call btc_toolchain_supply_fnc_list_grp2OnAdjust;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_uid", "_class", "_newAmount"];

private _inventory = (GVAR(table) getOrDefault [_uid, createHashMap]) getOrDefault ["inventory", createHashMap];
_inventory set [_class, _newAmount];
