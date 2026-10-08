#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_add

Description:
    Adds a new vehicle or ammo box class from EDIT_1 to LIST_1 and updates the internal table.

Parameters:
    _add: CONTROL - The button control clicked

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_list_grp1_add;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_add", controlNull, [controlNull]],
    ["_uid", "", [""]]
];

private _grp1 = ctrlParentControlsGroup _add;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;
private _edit = _grp1 controlsGroupCtrl EDIT_1;

private _class = "";
if (_uid isNotEqualTo "") then {
    private _inner = GVAR(table) getOrDefault [_uid, createHashMap];
    _class = _inner getOrDefault ["class", ""];
} else {
    _class = trim(ctrlText _edit);

    _uid = format["%1-%2", _class, ([] call EFUNC(tools,uid))];
    //table inits
    private _inner = GVAR(table) getOrDefault [_uid, createHashMap, true];
    _inner set ["class", _class];
    _inner set ["inventory", createHashMap];
};

private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith {
    [format["%1 invalid ammo box or vehicle class", _class], 1] call EFUNC(tools,3DENNotification);
};

private _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));

_grp1_list lbSetData [_row, _uid];
_grp1_list lbSetCurSel _row;
lbSort _grp1_list;

#ifdef BTC_DEBUG_SUPPLY
[["%1: adding %2 to LIST_1", __FILE_NAME__, _class], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
