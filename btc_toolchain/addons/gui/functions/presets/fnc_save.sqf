#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_save

Description:
    Saves current configuration to profileNamespace using the registered gather callback.

Parameters:
    _save: CONTROL - The save button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_saveButton] call btc_toolchain_gui_fnc_presets_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_save", controlNull, [controlNull]]
];
disableSerialization;

private _ctrlGrp = ctrlParentControlsGroup _save;
private _profileVar = _ctrlGrp getVariable [QGVAR(presets_profileVar), ""];
private _gatherData = _ctrlGrp getVariable [QGVAR(presets_gatherData), {}];

if (_profileVar isEqualTo "") exitWith {
    [["%1: No profileVar registered on presets controls group", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _edit = _ctrlGrp controlsGroupCtrl PRESETS_EDIT;
private _list = _ctrlGrp controlsGroupCtrl PRESETS_VALUE;

private _inner = [] call _gatherData;
if (_inner isEqualTo createHashMap || {_inner isEqualTo []}) exitWith {
    #ifdef BTC_DEBUG_GUI
    [["%1: gather callback returned empty data", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _savename = trim (ctrlText _edit);
if (_savename isEqualTo "") then {
    _savename = [] call EFUNC(tools,uid);
};

private _savedPresets = profileNamespace getVariable [_profileVar, createHashMap];
if (_savename in _savedPresets) then {
    [format ["Overwriting preset %1", _savename]] call EFUNC(tools,3DENNotification);
} else {
    [format ["Saving preset %1", _savename]] call EFUNC(tools,3DENNotification);
    private _row = _list lbAdd _savename;
    _list lbSetCurSel _row;
};

_savedPresets set [_savename, _inner];
profileNamespace setVariable [_profileVar, _savedPresets];
saveProfileNamespace;

