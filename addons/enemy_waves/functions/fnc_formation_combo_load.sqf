#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_formation_combo_load

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_formation_combo_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]],
    ["_value", "COLUMN", [""]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo load with _value %2", __FILE_NAME__, _value], LOGS, "enemy_waves"] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo FORMATION_COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, FORMATION_COMBO], REPORT, "enemy_waves"] call EFUNC(tools,debug);
};

lbClear _combo;

["COLUMN",
"STAG COLUMN",
"WEDGE",
"ECH LEFT",
"ECH RIGHT",
"VEE",
"LINE",
"FILE",
"DIAMOND"] apply {
	private _row = _combo lbAdd _x;
	if(_x isEqualTo _value) then {
		_combo lbSetCurSel _row;
	};
};
