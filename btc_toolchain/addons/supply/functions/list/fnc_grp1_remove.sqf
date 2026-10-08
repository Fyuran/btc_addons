#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_remove

Description:
    Removes the selected item in LIST_1 from the supply table and clears LIST_1 selection.

Parameters:
    _remove: CONTROL - The remove button control clicked

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_list_grp1_remove;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_remove", controlNull, [controlNull]],
    ["_uid", "", [""]]
];

private _grp1 = ctrlParentControlsGroup _remove;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

private _lbCurSel = lbCurSel _grp1_list;
if (_lbCurSel < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};

if (_uid isEqualTo "") then { //first check if uid has been passed
    _uid = _grp1_list lbData _lbCurSel;
};
if (_uid isEqualTo "") exitWith { //invalid uid, time to fuck off
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: invalid _uid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    _grp1_list lbDelete _lbCurSel;
};

GVAR(table) deleteAt _uid;

_grp1_list lbDelete _lbCurSel;
_grp1_list lbSetCurSel -1; //Should trigger LBSelChanged -1 exitWith lbClear

#ifdef BTC_DEBUG_SUPPLY
[["%1: removing %2 from LIST_1", __FILE_NAME__, _uid], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

