#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_side_combo_onLoad

Description:
    Initializes the side selection combo control in UI namespace with default side on dialog load.

Parameters:
    _comboGrp: CONTROL - Side combo box control group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_sideComboGrp] call btc_toolchain_enemy_waves_fnc_side_combo_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_comboGrp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];

disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing combo onLoad", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(side_combo), _combo];

lbClear _combo;

private _east_row = _combo lbAdd "OPFOR";
_combo lbSetValue[_east_row, 0];
_combo lbSetPicture[_east_row, "\a3\Data_f\cfgFactionClasses_OPF_ca.paa"];

private _west_row = _combo lbAdd "BLUFOR";
_combo lbSetValue[_west_row, 1];
_combo lbSetPicture[_west_row, "\a3\Data_f\cfgFactionClasses_BLU_ca.paa"];

private _ind_row = _combo lbAdd "INDFOR";
_combo lbSetValue[_ind_row, 2];
_combo lbSetPicture[_ind_row, "\a3\Data_f\cfgFactionClasses_IND_ca.paa"];

private _civ_row = _combo lbAdd "CIVILIANS";
_combo lbSetValue[_civ_row, 3];
_combo lbSetPicture[_civ_row, "\a3\Data_f\cfgFactionClasses_CIV_ca.paa"];

_combo lbSetCurSel 0;

