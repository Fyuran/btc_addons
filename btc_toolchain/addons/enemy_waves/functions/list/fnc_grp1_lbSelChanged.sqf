#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp1_lbSelChanged

Description:
    Handles selection changes in the groups listbox, populating the class listbox with vehicles/units.

Parameters:
    _grp1_list: CONTROL - The group listbox control
    _lbCurSel: NUMBER - The selected group index

Returns:
    NOTHING

Examples:
    (begin example)
        [_listControl, 0] call btc_toolchain_enemy_waves_fnc_list_grp1_lbSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_grp1_list", controlNull, [controlNull]],
    ["_lbCurSel", -1, [0]]
];

private _grp1 = ctrlParentControlsGroup _grp1_list;
private _main = ctrlParentControlsGroup _grp1;
private _grp2 = _main controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
lnbClear _grp2_list;

if (_lbCurSel < 0) exitWith {};

private _uid = _grp1_list lbData _lbCurSel;
private _groupClasses = GVAR(table) getOrDefault[_uid, []];

if (_groupClasses isEqualTo []) exitWith {}; //Empty

_groupClasses apply {
    _x params [
        ["_class", "", [""]],
        ["_amount", 1, [123]]
    ];

    if (!([_class] call EFUNC(tools,inheritsFromAny))) then {
        [format ["%1 class does not inherit from 'Land' or 'Air'", _class], 1] call EFUNC(tools,3DENNotification);
    };

    ([_class] call EFUNC(gui,getClassInfo)) params [
        ["_displayName", "UNKNOWN", [""]],
        ["_icon", "", [""]]
    ];

    private _row = _grp2_list lnbAddRow [_displayName, str _amount];
    _grp2_list lnbSetData [[_row, 0], _class];
    _grp2_list lnbSetPicture [[_row, 0], _icon];
};
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: filling VALUE_2's %2 with %3", __FILE_NAME__, _uid, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
