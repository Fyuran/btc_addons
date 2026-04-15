#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_combo_load

Description:
    Populates a combo box with available air vehicles and selects a specified vehicle.

Parameters:
    _combo[CONTROL]: Combo box control to populate
    _value[STRING]: Vehicle class name to select

Returns:
    NOTHING

Examples:
    (begin example)
        [_vehicleCombo, "B_Heli_Transport_01_F"] call btc_toolchain_supply_fnc_combo_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]],
    ["_value", "", []]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing combo load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, COMBO], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(!isClass (configFile >> "CfgVehicles" >> _value)) exitWith {};

lbClear _combo;
private _loadedSel = 0;
private _cfgVehicles = configFile >> "CfgVehicles";
private _configs = "(configName _x) isKindOf 'Air'" configClasses _cfgVehicles;
_configs = _configs select {getNumber (_x >> "scope") isEqualTo 2};
_configs apply {
    private _row = _combo lbAdd (getText (_x >> "displayName"));
    _combo lbSetPicture [_row, getText (_x >> "icon")];
    _combo lbSetData [_row, configName _x];
};
lbSort _combo;

//Find out if we have a match
for "_i" from 0 to (lbSize _combo) do {
    if((_combo lbData _i) isEqualTo _value) then {
        _loadedSel = _i;
        break;
    };
};

_combo lbSetCurSel _loadedSel;
