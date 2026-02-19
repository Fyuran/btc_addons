#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_combo_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_combo_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["% 1: executing combo init", __FILE_NAME__], CHAT, "enemy_waves"] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo COMBO) exitWith {
	[["% 1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, COMBO], REPORT, "enemy_waves"] call EFUNC(tools,debug);
};
private _side = lbCurSel _combo;
if(_side < 0 || _side > 3) exitWith {
    [["% 1: _side is out range must be between 0 and 3", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
    0
};

_side
