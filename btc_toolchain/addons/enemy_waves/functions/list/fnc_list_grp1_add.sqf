#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp1_add

Description:
    Adds a new group entry to the wave table and updates the group listbox.

Parameters:
    _add: CONTROL - The add button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_list_grp1_add;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_add", controlNull, [controlNull]]
];

private _grp1 = ctrlParentControlsGroup _add;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

//row inits
private _groupsCount = count GVAR(table); //new item
GVAR(table) pushBack [];

private _row = _grp1_list lbAdd (format["Group %1", _groupsCount + 1]);
_grp1_list lbSetCurSel _row;

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: adding new row: Group %2", __FILE_NAME__, _groupsCount + 1], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

