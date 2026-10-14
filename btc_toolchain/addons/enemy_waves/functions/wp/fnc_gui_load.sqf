#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_gui_load

Description:
    Applies value to Waypoint Type CT_TREE Control

Parameters:
    _ctrlGrp: CONTROL or ARRAY - Control group or controls to populate with waypoint types
    _value: ARRAY - Current waypoint type array (default: [[], "MOVE"])

Returns:
    NOTHING

Examples:
    (begin example)
        [_ctrlGrp, [[], "MOVE"]] call btc_toolchain_enemy_waves_fnc_wp_gui_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrlGrp", controlNull, [controlNull, []], [1, 2]],
    ["_value", [[], "MOVE"], [], 2]
];

private _treeCtrl = _ctrlGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_TYPE_VALUE;
if (isNull _treeCtrl) exitWith {
    [["%1: _treeCtrl is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_value params [
    ["_path", [], [[]]],
    ["_text", "MOVE", [""]]
];

if (_path isEqualTo []) then {
    private _parentsCount = _treeCtrl tvCount [];
    private _found = false;

    for "_i" from 0 to (_parentsCount - 1) do {
        if (_found) exitWith {};
        private _childrenCount = _treeCtrl tvCount [_i];

        for "_j" from 0 to (_childrenCount - 1) do {
            private _childText = _treeCtrl tvText [_i, _j];
            if (_childText isEqualTo "MOVE") exitWith {
                _path = [_i, _j];
                _found = true;
            };
        };
    };
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: _value is: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

_treeCtrl tvSetCurSel _path;
