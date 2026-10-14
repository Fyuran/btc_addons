#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_open

Description:
    Creates and displays a presets window, binding the specified profileNamespace variable
    and gather/apply callbacks to the control group.

Parameters:
    _presetsBtn: CONTROL - Presets button control
    _profileVar: STRING - profileNamespace variable name for saved presets
    _gatherData: CODE - Callback to gather preset data from controls, returning HASHMAP
    _applyData: CODE - Callback to apply preset data to controls, receiving HASHMAP

Returns:
    CONTROL - The presets controls group

Examples:
    (begin example)
        [_presetsBtn, "my_presets", _fncGather, _fncApply] call btc_toolchain_gui_fnc_presets_open;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_presetsBtn", controlNull, [controlNull]],
    ["_profileVar", "", [""]],
    ["_gatherData", {}, [{}]],
    ["_applyData", {}, [{}]]
];
disableSerialization;

private _presets = uiNamespace getVariable [QGVAR(presets_menu), controlNull];
if (isNull _presets) then {
    private _display = findDisplay IDD_DISPLAY3DENEDITATTRIBUTES;
    private _rscDisplayEmpty = _display createDisplay "RscDisplayEmpty";
    _presets = _rscDisplayEmpty ctrlCreate ["btc_toolchain_gui_ctrlPresets", PRESETS_MENU];
    uiNamespace setVariable [QGVAR(presets_menu), _presets];
};

if (isNull _presets) exitWith {
    #ifdef BTC_DEBUG_GUI
    [["%1: _presets failed to open", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    controlNull
};

_presets setVariable [QGVAR(presets_profileVar), _profileVar];
_presets setVariable [QGVAR(presets_gatherData), _gatherData];
_presets setVariable [QGVAR(presets_applyData), _applyData];

private _list = _presets controlsGroupCtrl PRESETS_VALUE;
lbClear _list;

private _savedPresets = profileNamespace getVariable [_profileVar, createHashMap];
_savedPresets apply {
    [_x, _y] params [
        "_savename",
        "_inner"
    ];
    private _row = _list lbAdd _savename;
    _list lbSetData [_row, toJSON _inner];
};

_presets

