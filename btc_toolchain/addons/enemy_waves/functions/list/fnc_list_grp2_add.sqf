#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp2_add

Description:
    Adds a new enemy class to the selected group and updates the classes listbox.

Parameters:
    _add: CONTROL - The add button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_list_grp2_add;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_add", controlNull, [controlNull]]
];

private _grp2 = ctrlParentControlsGroup _add;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _edit = _grp2 controlsGroupCtrl EDIT_2;
private _main = ctrlParentControlsGroup _grp2;
private _grp1 = _main controlsGroupCtrl GROUP_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;
private _groupIndex = lbCurSel _grp1_list;

//Update UI
if (_groupIndex < 0) exitWith {
    ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
};
private _groupClasses = GVAR(table) select _groupIndex;

private _class = trim(ctrlText _edit);
if (_class isEqualTo "") exitWith {
    ["Empty class passed", 1] call EFUNC(tools,3DENNotification);
};

private _classExists = (_groupClasses findIf {
    _x params["_c", "_amount"];
    _c isEqualTo _class;
}) isNotEqualTo -1;
if (_classExists) exitWith {
    [format["%1 class already exists", _class], 1] call EFUNC(tools,3DENNotification);
};

if (!([_class] call EFUNC(tools,inheritsFromAny))) then {
    [format["%1 class does not inherit from. 'Land' or 'Air'", _class], 1] call EFUNC(tools,3DENNotification);
};

private _classCfg = configFile >> "CfgVehicles" >> _class;
private _sideCombo = uiNamespace getVariable[QGVAR(side_combo), controlNull];
private _selectedSide = (_sideCombo lbValue (lbCurSel _sideCombo)) call BIS_fnc_sideType;
private _classFaction = (getNumber(configFile >> "CfgFactionClasses" >> (getText(_classCfg >> "faction")) >> "side")) call BIS_fnc_sideType;

if (_selectedSide isNotEqualTo _classFaction) exitWith {
    [format["%1's faction(%2) does not belong to %3", _class, str _classFaction, str _selectedSide], 1] call EFUNC(tools,3DENNotification);
};

private _lnbNewRow = [
    getText (_classCfg >> "displayName"),
    getText (_classCfg >> "icon"),
    1
];

_lnbNewRow params [
    ["_displayName", "UNKNOWN", [""]], 
    ["_icon", "", [""]],
    ["_amount", 1, [123]]
];

private _row = _grp2_list lnbAddRow [_displayName, str _amount];
_grp2_list lnbSetData [[_row, 0], _class];
_grp2_list lnbSetPicture [[_row, 0], _icon];
_grp2_list lnbSetCurSelRow _row;

//Update HashMap
_groupClasses pushBack [_class, 1];

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: Adding %2 to Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

