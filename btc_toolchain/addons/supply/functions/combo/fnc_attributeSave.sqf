#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_combo_attributeSave

Description:
    Returns the currently selected air vehicle class name from a combo box.

Parameters:
    _comboGrp: CONTROL - Combo box control group

Returns:
    STRING: Vehicle class name, empty string if no selection

Examples:
    (begin example)
        _vehicleClass = [_vehicleComboGrp] call btc_toolchain_supply_fnc_combo_attributeSave;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_comboGrp", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY
[["%1: executing combo save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _combo_curSel = lbCurSel _combo;
if(_combo_curSel < 0) exitWith {
    ""
};
private _chosen_veh = _combo lbData _combo_curSel;
if (isNil "_chosen_veh") exitWith {""};

_chosen_veh
