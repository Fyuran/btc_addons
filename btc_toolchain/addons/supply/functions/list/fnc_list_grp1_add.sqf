#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_add

Description:
    Adds a new vehicle or ammo box class from EDIT_1 to LIST_1 and updates the internal table.

Parameters:
    _add: CONTROL - The button control clicked

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_add"];

private _grp1 = ctrlParentControlsGroup _add;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;
private _edit = _grp1 controlsGroupCtrl EDIT_1;

private _class = trim(ctrlText _edit);
private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith {
    [format["%1 invalid ammo box or vehicle class", _class], 1] call EFUNC(tools,3DENNotification);
};

private _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));
lbSort _grp1_list;
_grp1_list lbSetCurSel _row;
//_grp1_list lbSetPicture [_row, getText (_cfg >> "icon")];

private _uid = format["%1-%2", _class, ([] call EFUNC(tools,uid))];
_grp1_list lbSetData [_row, _uid];

//table inits
private _inner = GVAR(table) getOrDefault [_uid, createHashMap, true];
_inner set ["class", _class];
_inner set ["inventory", createHashMap];

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: adding %2 to LIST_1", __FILE_NAME__, _class], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

