#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_presets_gatherData

Description:
    Gathers current enemy wave dialog attributes into a HashMap for preset saving.

Parameters:
    NONE

Returns:
    HASHMAP - Preset attribute data

Examples:
    (begin example)
        _presetData = [] call btc_toolchain_enemy_waves_fnc_presets_gatherData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
private _table = missionNamespace getVariable [QGVAR(table), createHashMap];
if (_table isEqualTo createHashMap) exitWith {
    [["No groups have been set yet"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    createHashMap
};

private _side_combo = uiNamespace getVariable [QGVAR(side_combo), controlNull];
private _timeout_edit = uiNamespace getVariable [QGVAR(timeout), controlNull];
private _seekEnd_cb = uiNamespace getVariable [QGVAR(seek_end), controlNull];

private _side = _side_combo lbValue (lbCurSel _side_combo);
private _timeout = parseNumber (ctrlText _timeout_edit);
private _seek_end = cbChecked _seekEnd_cb;

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: saving preset %2", __FILE_NAME__, createHashMapFromArray [
    [QGVAR(side), _side],
    [QGVAR(timeout), _timeout],
    [QGVAR(seek_end), _seek_end],
    [QGVAR(table), _table]
]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

createHashMapFromArray [
    [QGVAR(side), _side],
    [QGVAR(timeout), _timeout],
    [QGVAR(seek_end), _seek_end],
    [QGVAR(table), _table]
]

