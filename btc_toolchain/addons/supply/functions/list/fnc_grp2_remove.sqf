#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_remove

Description:
    Removes selected item from LIST_2 and deletes it from active object's inventory.

Parameters:
    _remove: CONTROL - The remove button clicked

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_list_grp2_remove;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_remove"];

private _grp2 = ctrlParentControlsGroup _remove;
private _main_grp = ctrlParentControlsGroup _grp2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

private _grp2_list_lnbCurSelRow = lnbCurSelRow _grp2_list;
if ((lbCurSel _grp1_list) < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};
if (_grp2_list_lnbCurSelRow < 0) exitWith {
    ["Nothing is selected in Supplies List", 1] call EFUNC(tools,3DENNotification);
};

//Update HashMap
private _uid = _grp1_list lbData (lbCurSel _grp1_list);
private _inventory = (GVAR(table) getOrDefault [_uid, createHashMap]) getOrDefault ["inventory", createHashMap];
if (_inventory isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: LIST_2 REMOVE _inventory is empty", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _class = _grp2_list lnbData [_grp2_list_lnbCurSelRow, 0];
_inventory deleteAt _class;

_grp2_list lnbDeleteRow _grp2_list_lnbCurSelRow;
_grp2_list lnbSetCurSelRow -1;

#ifdef BTC_DEBUG_SUPPLY
[["%1: removing %2 from LIST_2", __FILE_NAME__, _class], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

