#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_class_attributeLoad

Description:
    Populates a combo box with available classes and selects a specified class.

Parameters:
    _comboGrp: CONTROL - Combo box control group
    _value: STRING - Class name to select

Returns:
    NOTHING

Examples:
    (begin example)
        [_comboGrp, "B_Heli_Transport_01_F"] call btc_toolchain_gui_fnc_class_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_comboGrp", controlNull, [controlNull]],
    ["_value", "", [""]]
];

private _editDisplay = ctrlParent _comboGrp;
if (isNull _editDisplay) then {
    _editDisplay = findDisplay IDD_DISPLAY3DEN;
};
if (isNull _editDisplay) exitWith {
    [["%1: _editDisplay not open", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Find out if we have a match
private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2, allControls: %3", __FILE_NAME__, _this, allControls _editDisplay], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _loadedSel = -1;
private _comboCount = lbSize _combo;
for "_i" from 0 to (_comboCount - 1) do {
    if ((_combo lbData _i) isEqualTo _value) then {
        _loadedSel = _i;
        break;
    };
};

if (_loadedSel > -1) then {
    _combo lbSetCurSel _loadedSel;
};
