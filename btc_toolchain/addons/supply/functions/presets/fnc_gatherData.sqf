#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_presets_gatherData

Description:
    Gathers current supply dialog attributes into a HashMap for preset saving.

Parameters:
    NONE

Returns:
    HASHMAP - Preset attribute data

Examples:
    (begin example)
        _presetData = [] call btc_toolchain_supply_fnc_presets_gatherData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
private _vehicleClassCombo = uiNamespace getVariable [QGVAR(vehicleClass), controlNull];
private _enableDamageCb = uiNamespace getVariable [QGVAR(enableDamage), controlNull];

private _vehicleClass = _vehicleClassCombo lbData (lbCurSel _vehicleClassCombo);
private _enableDamage = [false, true] select (cbChecked _enableDamageCb);

private _table = +(missionNamespace getVariable [QGVAR(table), createHashMap]);
if (_table isEqualTo createHashMap) exitWith {
    [["No inventory has been set yet"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    createHashMap
};

#ifdef BTC_DEBUG_SUPPLY
[["%1: saving preset %2", __FILE_NAME__, createHashMapFromArray [
    [QGVAR(table_vehicle), _vehicleClass],
    [QGVAR(table_enableDamage), _enableDamage],
    [QGVAR(table), _table]
]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

createHashMapFromArray [
    [QGVAR(table_vehicle), _vehicleClass],
    [QGVAR(table_enableDamage), _enableDamage],
    [QGVAR(table), _table]
]

