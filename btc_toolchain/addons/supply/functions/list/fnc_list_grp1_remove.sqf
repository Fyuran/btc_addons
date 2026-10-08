#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_remove

Description:
    Removes the selected item in LIST_1 from the supply table and clears LIST_1 selection.

Parameters:
    _remove: CONTROL - The remove button control clicked

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_remove"];

private _grp1 = ctrlParentControlsGroup _remove;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

private _lbCurSel = lbCurSel _grp1_list;
if (_lbCurSel < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};

private _uid = _grp1_list lbData _lbCurSel;
GVAR(table) deleteAt _uid;

_grp1_list lbDelete _lbCurSel;
_grp1_list lbSetCurSel -1; //Should trigger LBSelChanged -1 exitWith lbClear

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: removing %2 from LIST_1", __FILE_NAME__, _uid], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

