#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_list_onLoad

Description:
    Initializes the vehicle data list controls group and stores references in uiNamespace on dialog load.

Parameters:
    _main_grp: CONTROL - Main controls group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_mainGroupControl] call btc_toolchain_cas_fnc_list_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_main_grp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];
disableSerialization;

#ifdef BTC_DEBUG_CAS
[["%1: executing list_grp onLoad with ctrl: %2", __FILE_NAME__, _main_grp], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

GVAR(table) = createHashMap;
uiNamespace setVariable [QGVAR(vehicleDataGrp), _main_grp];

//get controls refs
private _classGrp = _main_grp controlsGroupCtrl VEHICLE_CLASS;
private _grp1ListGrp = _main_grp controlsGroupCtrl LIST_1;

private _classCombo = _classGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
private _grp1List = _grp1ListGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

if (isNull _classCombo || isNull _grp1List) exitWith {
    [["%1: null ctrls found: %2, %3", __FILE_NAME__, _classCombo, _grp1List], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

[_classGrp, "Air", FUNC(class_hasWeapons)] call EFUNC(gui,class_onLoad);
