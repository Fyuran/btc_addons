#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp2_buttonRight

Description:
    Increments the unit amount for the selected class in the classes listbox.

Parameters:
    _btn: CONTROL - The right arrow button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_list_grp2_buttonRight;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_btn", controlNull, [controlNull]]
];

private _grp2 = ctrlParentControlsGroup _btn;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _main = ctrlParentControlsGroup _grp2;
private _grp1 = _main controlsGroupCtrl GROUP_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

private _groupIndex = lbCurSel _grp1_list;
if (_groupIndex < 0) exitWith {
    ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
};

private _enemyClassIndex = lnbCurSelRow _grp2_list;
if (_enemyClassIndex < 0) exitWith {
    ["Nothing is selected in Enemy Classes List", 1] call EFUNC(tools,3DENNotification);
};

//Update HashMap
private _groupClasses = GVAR(table) select _groupIndex;
if (_groupClasses isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
    [["%1: LIST_2 buttonRight's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _group = _groupClasses select _enemyClassIndex;
_group params ["_class", "_amount"];
_group set [1, _amount + 1];

//Update UI
_grp2_list lnbSetText [[_enemyClassIndex, 1], str (_amount + 1)];

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: Adding 1 of %2 to Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

