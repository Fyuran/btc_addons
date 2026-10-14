#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp1_remove

Description:
    Removes the selected group entry from the wave table and refreshes the list.

Parameters:
    _remove: CONTROL - The remove button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_list_grp1_remove;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_remove", controlNull, [controlNull]]
];

private _grp1 = ctrlParentControlsGroup _remove;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

private _groupIndex = lbCurSel _grp1_list;
if (_groupIndex < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};
GVAR(table) deleteAt _groupIndex;
_grp1_list lbSetCurSel -1; //Triggers LBSelChanged exitWith lbClear
lbClear _grp1_list;
for "_i" from 1 to (count GVAR(table)) do { //Groups are malformed after delete in middle of list, so remake them from scratch to be back in numeric order
	_grp1_list lbAdd (format["Group %1", _i]);
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: removing _row %2 with Group %3", __FILE_NAME__, _groupIndex, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

