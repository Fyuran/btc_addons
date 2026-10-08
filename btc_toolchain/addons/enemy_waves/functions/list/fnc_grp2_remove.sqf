#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp2_remove

Description:
    Removes the selected enemy class from the selected group and updates the classes listbox.

Parameters:
    _remove: CONTROL - The remove button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_list_grp2_remove;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_remove", controlNull, [controlNull]]
];

private _grp2 = ctrlParentControlsGroup _remove;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
private _main = ctrlParentControlsGroup _grp2;
private _grp1 = _main controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

private _enemyClassIndex = lnbCurSelRow _grp2_list;
if ((lbCurSel _grp1_list) < 0) exitWith {
    ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
};
if (_enemyClassIndex < 0) exitWith {
    ["Nothing is selected in Enemy Classes List", 1] call EFUNC(tools,3DENNotification);
};

//Update HashMap
private _groupIndex = lbCurSel _grp1_list;
if (_groupIndex < 0) exitWith {
    ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
};

private _uid = _grp1_list lbData _groupIndex;
private _groupClasses = GVAR(table) getOrDefault [_uid, []];
if (_groupClasses isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: VALUE_2 REMOVE's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _class = _groupClasses deleteAt _enemyClassIndex;
_grp2_list lnbDeleteRow _enemyClassIndex;
_grp2_list lnbSetCurSelRow -1;

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: Removing %2 from Wave %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

