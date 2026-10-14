#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_presets_applyData

Description:
    Applies loaded preset attributes to the supply dialog controls.

Parameters:
    _preset: HASHMAP - Loaded preset data

Returns:
    NOTHING

Examples:
    (begin example)
        [_presetData] call btc_toolchain_supply_fnc_presets_applyData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_preset", createHashMap, [createHashMap]]
];

private _checkbox = uiNamespace getVariable [QGVAR(enableDamage), controlNull];
private _combo = uiNamespace getVariable [QGVAR(vehicleClass), controlNull];
private _list_grps = uiNamespace getVariable [QGVAR(list_grps), controlNull];

if (isNull _checkbox || isNull _combo || isNull _list_grps) exitWith {
    [["%1: Supply gui malfunctioned, one control is null: _checkbox %2, _combo: %3, _list_grps: %4", __FILE_NAME__, _checkbox, _combo, _list_grps], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_SUPPLY
[["%1: loading preset %2", __FILE_NAME__, _preset], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

[ctrlParentControlsGroup _combo, _preset getOrDefault [QGVAR(table_vehicle), "B_Heli_Light_01_F"]] call FUNC(combo_attributeLoad);
_checkbox cbSetChecked (_preset getOrDefault [QGVAR(table_allowDamage), true]);
[_list_grps, _preset getOrDefault [QGVAR(table), createHashMap]] call FUNC(list_attributeLoad);

