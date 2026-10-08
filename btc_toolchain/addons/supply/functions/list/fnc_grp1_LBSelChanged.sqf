#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_LBSelChanged

Description:
    Updates LIST_2 inventory display when selection in LIST_1 changes.

Parameters:
    _grp1_list: CONTROL - The list control
    _lbCurSel: NUMBER - The selected index

Returns:
    NOTHING

Examples:
    (begin example)
        [_listControl, 0] call btc_toolchain_supply_fnc_list_grp1_LBSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_grp1_list", "_lbCurSel"];

private _grp1 = ctrlParentControlsGroup _grp1_list;
private _main_grp = ctrlParentControlsGroup _grp1;
private _grp2 = _main_grp controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;

if (_lbCurSel < 0) exitWith {
    lnbClear _grp2_list;
};

//retrieve LIST_1 lbCurSel's data from the HashMap
private _uid = _grp1_list lbData _lbCurSel;
private _inventory = (GVAR(table) getOrDefault [_uid, createHashMap]) getOrDefault ["inventory", createHashMap];

lnbClear _grp2_list;
if (_inventory isEqualTo createHashMap) exitWith {}; //empty

_inventory apply {
    [_x, _y] params [
        ["_class", "", [""]],
        ["_amount", 1, [123]]
    ];

    ([_class] call EFUNC(gui,getClassInfo)) params [
        ["_displayName", "", [""]],
        ["_icon", "", [""]]
    ];

    if (_displayName isEqualTo "") then {
        [format ["%1 invalid vehicle, weapon or magazine class", _class], 1] call EFUNC(tools,3DENNotification);
        continue;
    };

    private _row = _grp2_list lnbAddRow [_displayName, str _amount];
    _grp2_list lnbSetData [[_row, 0], _class];
    _grp2_list lnbSetPicture [[_row, 0], _icon];
};
_grp2_list lnbSort [0, true];

#ifdef BTC_DEBUG_SUPPLY
[["%1: building LIST_2 with inventory: %2", __FILE_NAME__, _inventory], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
