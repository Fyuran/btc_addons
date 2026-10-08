#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_type_attributeSave

Description:
    Retrieves waypoint type value

Parameters:
    _ctrlGrp: CONTROL - Control group

Returns:
    STRING

Examples:
    (begin example)
        [_ctrlGrp] call btc_toolchain_enemy_waves_fnc_type_attributeSave;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrlGrp", controlNull, [controlNull]]
];

private _treeCtrl = _ctrlGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_TYPE_VALUE;
if (isNull _treeCtrl) exitWith {
    [["%1: _treeCtrl is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing wp attributeSave with tvData: %2", __FILE_NAME__, _treeCtrl tvData (tvCurSel _treeCtrl)], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

_treeCtrl tvData (tvCurSel _treeCtrl) 
