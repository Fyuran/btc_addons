#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_presets_applyData

Description:
    Applies loaded preset attributes to the enemy wave dialog controls.

Parameters:
    _preset: HASHMAP - Loaded preset data

Returns:
    NOTHING

Examples:
    (begin example)
        [_presetData] call btc_toolchain_enemy_waves_fnc_presets_applyData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_preset", createHashMap, [createHashMap]]
];

private _side_combo = uiNamespace getVariable [QGVAR(side_combo), controlNull];
private _timeout = uiNamespace getVariable [QGVAR(timeout), controlNull];
private _seekEnd_cb = uiNamespace getVariable [QGVAR(seek_end), controlNull];
private _list_grps = uiNamespace getVariable [QGVAR(list_grps), controlNull];

if (isNull _side_combo || isNull _timeout || isNull _seekEnd_cb || isNull _list_grps) exitWith {
    [["%1: Enemy waves gui malfunctioned, one control is null: _side_combo %2, _timeout: %3, _seekEnd_cb: %4, _list_grps: %5", __FILE_NAME__, _side_combo, _timeout, _seekEnd_cb, _list_grps], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: loading preset %2", __FILE_NAME__, _preset], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

[_side_combo, _preset getOrDefault [QGVAR(side), east]] call FUNC(side_combo_attributeLoad);
[_timeout, _preset getOrDefault [QGVAR(timeout), 60]] call FUNC(timeout_attributeLoad);

private _seek_end = _preset getOrDefault [QGVAR(seek_end), true];
_seekEnd_cb cbSetChecked _seek_end;

[_list_grps, _preset getOrDefault [QGVAR(table), createHashMap]] call FUNC(list_attributeLoad);

