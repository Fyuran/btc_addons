#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp2OnAdjust

Description:
    Callback invoked by GUI list arrow adjust to update wave group unit count.

Parameters:
    _uid: ANY
    _newAmount: NUMBER - New unit quantity
    _grp2_curSelRow: NUMBER - Selected class row index

Returns:
    NOTHING

Examples:
    (begin example)
        ["Wave-1", "", 2] call btc_toolchain_enemy_waves_fnc_list_grp2OnAdjust;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_uid", "", "_newAmount", "", "_grp2_curSelRow"];

private _groupClasses = GVAR(table) getOrDefault [_uid, []];
private _group = _groupClasses select _grp2_curSelRow;
_group set [1, _newAmount]; //Class, Amount
