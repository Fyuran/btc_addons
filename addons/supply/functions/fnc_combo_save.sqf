#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_combo_save

Description:
    Returns the currently selected air vehicle class name from a combo box.

Parameters:
    _combo[CONTROL]: Combo box control to query

Returns:
    STRING: Vehicle class name, empty string if no selection

Examples:
    (begin example)
        _vehicleClass = [_vehicleCombo] call btc_supply_fnc_combo_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing combo save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
if((ctrlIDC _combo) isNotEqualTo COMBO) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _combo, COMBO], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _combo_curSel = lbCurSel _combo;
if(_combo_curSel < 0) exitWith {
    ""
};
private _chosen_veh = _combo lbData _combo_curSel;

_chosen_veh
