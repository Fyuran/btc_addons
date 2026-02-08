#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_combo_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_combo_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing combo init", __FILE__], 2, "supply"] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE__, ctrlIDC _combo, COMBO], 6, "supply"] call EFUNC(tools,debug);
};
private _combo_curSel = lbCurSel _combo;
if(_combo_curSel < 0) exitWith {
    ""
};
private _chosen_veh = _combo lbData _combo_curSel;

_chosen_veh
