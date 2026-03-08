#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_side_combo_load

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_enemy_waves_fnc_side_combo_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]],
    ["_value", 0, [123, ""]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo SIDE_COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, SIDE_COMBO], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

/*
0 = opfor (east) "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
1 = blufor (west) "\a3\Data_f\cfgFactionClasses_BLU_ca.paa";
2 = independent (resistance) "\a3\Data_f\cfgFactionClasses_IND_ca.paa";
3 = civilian "\a3\Data_f\cfgFactionClasses_CIV_ca.paa";
*/
if(_value isEqualType "") then {
	_value = parseNumber _value;
};

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

if(_value < 0 || _value > 3) exitWith {
    [["%1: _value is out range must be between 0 and 3", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_combo lbSetCurSel _value;
