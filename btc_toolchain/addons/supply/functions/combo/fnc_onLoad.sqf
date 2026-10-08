#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_combo_onLoad

Description:
    Initializes a combo box with available air vehicle classes from config and stores reference on dialog load.

Parameters:
    _comboGrp: CONTROL - Combo box control group to populate with aircraft
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_comboGrp] call btc_toolchain_supply_fnc_combo_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_comboGrp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY
[["%1: executing combo onLoad", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(vehicleClass), _combo];

//Combo
lbClear _combo;
private _cfgVehicles = configFile >> "CfgVehicles";
private _configs = "(configName _x) isKindOf 'Air'" configClasses _cfgVehicles;
_configs = _configs select {getNumber (_x >> "scope") isEqualTo 2};
_configs apply {
    private _row = _combo lbAdd (getText (_x >> "displayName"));
    _combo lbSetPicture [_row, getText (_x >> "icon")];
    _combo lbSetData [_row, configName _x];
};

lbSort _combo;
_combo lbSetCurSel 0;

