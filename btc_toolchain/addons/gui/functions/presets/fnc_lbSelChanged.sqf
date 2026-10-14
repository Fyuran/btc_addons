#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_lbSelChanged

Description:
    Updates the preset edit box when a preset is selected from the listbox.

Parameters:
    _list: CONTROL - The presets listbox control
    _lbCurSel: NUMBER - The selected index in the listbox

Returns:
    NOTHING

Examples:
    (begin example)
        [_listControl, 0] call btc_toolchain_gui_fnc_presets_lbSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_list", controlNull, [controlNull]],
    ["_lbCurSel", -1, [0]]
];
disableSerialization;

if (_lbCurSel < 0) exitWith {};

private _ctrlGrp = ctrlParentControlsGroup _list;
private _edit = _ctrlGrp controlsGroupCtrl PRESETS_EDIT;
private _savename = _list lbText _lbCurSel;
_edit ctrlSetText _savename;

