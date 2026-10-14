#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_load

Description:
    Loads the selected preset from profileNamespace and applies it via the registered apply callback.

Parameters:
    _load: CONTROL - The load button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_loadButton] call btc_toolchain_gui_fnc_presets_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_load", controlNull, [controlNull]]
];
disableSerialization;

private _ctrlGrp = ctrlParentControlsGroup _load;
private _profileVar = _ctrlGrp getVariable [QGVAR(presets_profileVar), ""];
private _applyData = _ctrlGrp getVariable [QGVAR(presets_applyData), {}];

if (_profileVar isEqualTo "") exitWith {
    [["%1: No profileVar registered on presets controls group", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _list = _ctrlGrp controlsGroupCtrl PRESETS_VALUE;
private _lbCurSel = lbCurSel _list;
if (_lbCurSel < 0) exitWith {
    ["Nothing is selected", 1] call EFUNC(tools,3DENNotification);
};

private _savedPresets = profileNamespace getVariable [_profileVar, createHashMap];
if (_savedPresets isEqualTo createHashMap) exitWith {
    [["No presets found in profileNamespace"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _savename = _list lbText _lbCurSel;
private _preset = _savedPresets getOrDefault [_savename, createHashMap];
if (_preset isEqualTo createHashMap) exitWith {
    [["No preset found in profileNamespace by %1 name", _savename], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

[_preset] call _applyData;

#ifdef BTC_DEBUG_GUI
[["%1: Loaded preset %2 with data %3", __FILE_NAME__, _savename, _preset], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

[format ["Loaded preset %1", _savename]] call EFUNC(tools,3DENNotification);

private _presets = ctrlParent _load;
_presets closeDisplay 1;

