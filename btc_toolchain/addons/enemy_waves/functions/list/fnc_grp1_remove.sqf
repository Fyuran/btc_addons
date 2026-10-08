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
    [["%1: invalid _uid: %2", __FILE_NAME__, _uid], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    
};

GVAR(table) deleteAt _uid;
_grp1_list lbDelete _lbCurSel;
_grp1_list lbSetCurSel -1; //Triggers lbSelChanged exitWith lnbClear

private _tableCount = count GVAR(table);
for "_i" from 0 to (_tableCount - 1) do { //Groups' names are malformed when removing middle, rename them correctly
    _grp1_list lbSetText [_i, format["Wave %1", _i + 1]];
};


#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: removing Wave %2", __FILE_NAME__, _uid], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
