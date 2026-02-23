#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_formation_combo_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_formation_combo_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo save", __FILE_NAME__], LOGS, "enemy_waves"] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo FORMATION_COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, FORMATION_COMBO], REPORT, "enemy_waves"] call EFUNC(tools,debug);
};

_combo lbText (lbCurSel _combo)
