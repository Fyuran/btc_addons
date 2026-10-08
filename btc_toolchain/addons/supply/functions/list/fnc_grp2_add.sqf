#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_add

Description:
    Adds a new inventory class to LIST_2 if valid and updates the HashMap.

Parameters:
    _add: CONTROL - The button control clicked

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_list_grp2_add;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_add"];

private _grp2 = ctrlParentControlsGroup _add;
private _main = ctrlParentControlsGroup _grp2;
private _edit = _grp2 controlsGroupCtrl EDIT_2;
private _grp1 = _main controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

if ((lbCurSel _grp1_list) < 0) exitWith {
    ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
};

private _class = trim (ctrlText _edit);
//Update HashMap
private _uid = _grp1_list lbData (lbCurSel _grp1_list);
private _inventory = (GVAR(table) getOrDefault [_uid, createHashMap]) getOrDefault ["inventory", createHashMap];

if (_class in _inventory) exitWith {
    [format ["%1 already exists inside this object's inventory", _class], 1] call EFUNC(tools,3DENNotification);
};

([_class] call EFUNC(gui,getClassInfo)) params [
    ["_displayName", "", [""]],
    ["_icon", "", [""]],
    ["_cfgType", "", [""]]
];

if (_displayName isEqualTo "" || {!(_cfgType in ["CfgWeapons", "CfgMagazines"])}) exitWith {
    [format ["%1 invalid inventory class", _class], 1] call EFUNC(tools,3DENNotification);
};

_inventory set [_class, 1];

//Add new entry
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
private _row = _grp2_list lnbAddRow [_displayName, "1"];
_grp2_list lnbSort [0, true];
_grp2_list lnbSetData [[_row, 0], _class];
_grp2_list lnbSetPicture [[_row, 0], _icon];
_grp2_list lnbSetCurSelRow _row;

#ifdef BTC_DEBUG_SUPPLY
[["%1: adding %2 to VALUE_2", __FILE_NAME__, _class], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
