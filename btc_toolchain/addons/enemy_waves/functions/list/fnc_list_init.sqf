#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_init

Description:
    Initializes the wave configuration lists and UI event handlers for group and unit composition.

Parameters:
    _main_grp: CONTROL

Returns:

Examples:
    (begin example)
        [_mainGroupControl] call btc_toolchain_enemy_waves_fnc_list_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull, []], [1, 2]]
];
_main_grp = if (_main_grp isEqualType []) then {_main_grp select 0} else {_main_grp};
disableSerialization;

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing list init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
GVAR(table) = [];
uiNamespace setVariable[QGVAR(list_grp), _main_grp];

//Group 1
private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
if((ctrlIDC _grp1) isNotEqualTo GROUP_1) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp1, GROUP_1], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _grp1_add = _grp1 controlsGroupCtrl ADD_1;
private _grp1_remove = _grp1 controlsGroupCtrl REMOVE_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

_grp1_add ctrlAddEventHandler ["ButtonClick", FUNC(list_grp1_add)];
_grp1_remove ctrlAddEventHandler ["ButtonClick", FUNC(list_grp1_remove)];
_grp1_list ctrlAddEventHandler ["LBSelChanged", FUNC(list_grp1_lbSelChanged)];

//Group 2
private _grp2 = _main_grp controlsGroupCtrl GROUP_2;
if((ctrlIDC _grp2) isNotEqualTo GROUP_2) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp2, GROUP_2], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _grp2_add = _grp2 controlsGroupCtrl ADD_2;
private _grp2_remove = _grp2 controlsGroupCtrl REMOVE_2;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _grp2_list2_buttonLeft = _grp2 controlsGroupCtrl ARROWLEFT;
private _grp2_list2_buttonRight = _grp2 controlsGroupCtrl ARROWRIGHT;

_grp2_add ctrlAddEventHandler ["ButtonClick", FUNC(list_grp2_add)];
_grp2_remove ctrlAddEventHandler ["ButtonClick", FUNC(list_grp2_remove)];

if(isServer) then {
    _grp2_list ctrlAddEventHandler ["KeyDown", FUNC(list_grp2_keyDown)];
};

_grp2_list2_buttonLeft ctrlAddEventHandler ["ButtonClick", FUNC(list_grp2_buttonLeft)];
_grp2_list2_buttonRight ctrlAddEventHandler ["ButtonClick", FUNC(list_grp2_buttonRight)];
