#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_gui_save

Description:
    Retrieves waypoint type value

Parameters:
    _ctrlGrp: CONTROL or ARRAY - Control group or controls to retrieve selected waypoint type from

Returns:
    ARRAY

Examples:
    (begin example)
        [_ctrlGrp] call btc_toolchain_enemy_waves_fnc_wp_gui_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrlGrp", controlNull, [controlNull, []], [1, 2]]
];

private _treeCtrl = _ctrlGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_TYPE_VALUE;
if (isNull _treeCtrl) exitWith {
    [["%1: _treeCtrl is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _data = _treeCtrl tvData (tvCurSel _treeCtrl);
_data params [
    ["_path", [], [[]]],
    ["_text", "MOVE", [""]]
];

if (_text isEqualTo "") then {
    _text = "MOVE";
};

[tvCurSel _treeCtrl, [_path, _text]]
