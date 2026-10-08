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
    ["_add", controlNull, [controlNull]],
    ["_uid", "", [""]]
];

private _grp1 = ctrlParentControlsGroup _add;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

//row inits
private _groupsCount = lbSize _grp1_list;

private _lbRowText = format["Wave %1", _groupsCount + 1];
private _row = _grp1_list lbAdd _lbRowText;

if (_uid isEqualTo "") then {
    _uid = format["%1-%2", _lbRowText, ([] call EFUNC(tools,uid))];
    GVAR(table) set[_uid, []];
};

_grp1_list lbSetData [_row, _uid];
_grp1_list lbSetCurSel _row;

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: adding new row: Wave %2", __FILE_NAME__, _lbRowText], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

//lbSort _grp1_list;

_row
