#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_buttonLeft

Description:
    Decrements quantity for selected supply item in LIST_2.

Parameters:
    _btn: CONTROL

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_btn"];

private _grp2 = ctrlParentControlsGroup _btn;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _main = ctrlParentControlsGroup _grp2;
private _grp1 = _main controlsGroupCtrl GROUP_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

private _grp2_list_lnbCurSelRow = lnbCurSelRow _grp2_list;
if ((lbCurSel _grp1_list) < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};
if (_grp2_list_lnbCurSelRow < 0) exitWith {
    ["Nothing is selected in Supplies List", 1] call EFUNC(tools,3DENNotification);
};

//Update HashMap
private _uid = _grp1_list lbData (lbCurSel _grp1_list);
private _inventory = (GVAR(table) get _uid) get "inventory";
if (_inventory isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_SUPPLY_DIALOG
    [["%1: LIST_2 buttonLeft _inventory is empty", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _class = _grp2_list lnbData [_grp2_list_lnbCurSelRow, 0];
private _amount = _inventory get _class;
_inventory set [_class, (_amount - 1) max 1];

//Update UI
_grp2_list lnbSetText [[_grp2_list_lnbCurSelRow, 1], str ((_amount - 1) max 1)];
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: adding 1 LIST_2's class: ", __FILE_NAME__, _class], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

