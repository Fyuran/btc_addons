#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_onAdjust

Description:
    Callback invoked by GUI list arrow adjust to update supply item quantity.

Parameters:
    _uid: STRING - Container UID
    _class: STRING - Item class name
    _newAmount: NUMBER - New quantity
    _grp1_curSel: NUMBER - Selected container index (unused)
    _grp2_curSelRow: NUMBER - Selected item row index (unused)

Returns:
    NOTHING

Examples:
    (begin example)
        ["uid_123", "FirstAidKit", 5] call btc_toolchain_supply_fnc_list_grp2_onAdjust;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_uid", "_class", "_newAmount"];

private _inventory = (GVAR(table) get _uid) get "inventory";
_inventory set [_class, _newAmount];

