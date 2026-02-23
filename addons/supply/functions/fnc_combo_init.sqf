#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_combo_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_combo_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing combo init", __FILE_NAME__], LOGS, "supply"] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, COMBO], REPORT, "supply"] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(combo), _combo];

//Combo
private _cfgVehicles = configFile >> "CfgVehicles";
private _configs = "(configName _x) isKindOf 'Air'" configClasses _cfgVehicles;
_configs = _configs select {getNumber (_x >> "scope") isEqualTo 2};
_configs apply {
    private _row = _combo lbAdd (getText (_x >> "displayName"));
    _combo lbSetPicture [_row, getText (_x >> "icon")];
    _combo lbSetData [_row, configName _x];
};
_combo lbSetCurSel 0;
