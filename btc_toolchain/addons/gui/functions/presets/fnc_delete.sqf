#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_delete

Description:
    Deletes the selected preset from profileNamespace and removes it from the presets listbox.

Parameters:
    _delete: CONTROL - The delete button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_deleteButton] call btc_toolchain_gui_fnc_presets_delete;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_delete", controlNull, [controlNull]]
];
disableSerialization;

private _ctrlGrp = ctrlParentControlsGroup _delete;
private _profileVar = _ctrlGrp getVariable [QGVAR(presets_profileVar), ""];
private _list = _ctrlGrp controlsGroupCtrl PRESETS_VALUE;

private _lbCurSel = lbCurSel _list;
if (_lbCurSel < 0) exitWith {
    ["Nothing is selected", 1] call EFUNC(tools,3DENNotification);
};

if (_profileVar isEqualTo "") exitWith {
    [["%1: No profileVar registered on presets controls group", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _savedPresets = profileNamespace getVariable [_profileVar, createHashMap];
_savedPresets deleteAt (_list lbText _lbCurSel);

#ifdef BTC_DEBUG_GUI
[["%1: removing preset: %2 from %3", __FILE_NAME__, _list lbText _lbCurSel, _profileVar], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

_list lbDelete _lbCurSel;
profileNamespace setVariable [_profileVar, _savedPresets];
saveProfileNamespace;

