#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_class_attributeSave

Description:
    Returns the currently selected class name from a combo box.

Parameters:
    _comboGrp: CONTROL - Combo box control group

Returns:
    STRING - Class name, empty string if no selection

Examples:
    (begin example)
        _class = [_comboGrp] call btc_toolchain_gui_fnc_class_attributeSave;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_comboGrp", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_GUI
[["%1: executing class attributeSave", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    ""
};

private _combo_curSel = lbCurSel _combo;
if (_combo_curSel < 0) exitWith {
    ""
};
private _chosen_class = _combo lbData _combo_curSel;
if (isNil "_chosen_class") exitWith {""};

_chosen_class
