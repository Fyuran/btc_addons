#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_list_attributeSave

Description:
    Returns the currently selected indices of LIST_1 and LIST_2 as an array.

Parameters:
    _main_grp: CONTROL - Main vehicleData controls group

Returns:
    ARRAY - [weaponIndex, modeIndex]

Examples:
    (begin example)
        _indices = [_vehicleDataGrp] call btc_toolchain_cas_fnc_list_attributeSave;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_main_grp", controlNull, [controlNull]]
];
disableSerialization;

//get controls refs
private _classGrp = _main_grp controlsGroupCtrl VEHICLE_CLASS;
private _grp1ListGrp = _main_grp controlsGroupCtrl LIST_1;

private _classCombo = _classGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
private _grp1List = _grp1ListGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

if (isNull _classCombo || isNull _grp1List) exitWith {
    [["%1: null ctrls found: %2, %3", __FILE_NAME__, _classCombo, _grp1List], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_CAS
[["%1: executing list attributeSave with _ctrl:%2", __FILE_NAME__, _main_grp], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

//Class save
GVAR(table) set ["class", _classCombo lbData (lbCurSel _classCombo)];

private _listData = (lbSelection _grp1List) apply {
    _grp1List lbData _x;
};
GVAR(table) set ["listData", _listData];

GVAR(table)
