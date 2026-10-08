#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_lbSelChanged

Description:
    Updates LIST_2 inventory display when selection in LIST_1 changes.

Parameters:
    _grp1_list: CONTROL - The list control
    _lbCurSel: NUMBER - The selected index

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_grp1_list", "_lbCurSel"];

private _grp1 = ctrlParentControlsGroup _grp1_list;
private _main = ctrlParentControlsGroup _grp1;
private _grp2 = _main controlsGroupCtrl GROUP_2;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;

if (_lbCurSel < 0) exitWith {
    lnbClear _grp2_list;
};

//retrieve LIST_1 lbCurSel's data from the HashMap
private _uid = _grp1_list lbData _lbCurSel;
private _inventory = (GVAR(table) get _uid) get "inventory";

lnbClear _grp2_list;
if (_inventory isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_SUPPLY_DIALOG
    [["%1: LIST_1 LBSelChanged's _inventory is empty", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

_inventory apply {
    [_x, _y] params [
        ["_class", "", [""]],
        ["_amount", 1, [123]]
    ];
    private _lnbNewRow = switch (true) do {
        case (isClass (configFile >> "CfgVehicles" >> _class)): {
            [
                getText (configFile >> "CfgVehicles" >> _class >> "displayName"),
                getText (configFile >> "CfgVehicles" >> _class >> "icon"),
                _amount
            ]
        };
        case (isClass (configFile >> "CfgWeapons" >> _class)): {
            [
                getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
                getText (configFile >> "CfgWeapons" >> _class >> "picture"),
                _amount
            ]
        };
        case (isClass (configFile >> "CfgMagazines" >> _class)): {
            [
                getText (configFile >> "CfgMagazines" >> _class >> "displayName"),
                getText (configFile >> "CfgMagazines" >> _class >> "picture"),
                _amount
            ]
        };
        default {
            [
                "REPORT",
                "REPORT",
                -1
            ]
        };
    };

    _lnbNewRow params [
        ["_displayName", "UNKNOWN", [""]], 
        ["_icon", "", [""]],
        ["_amount", 1, [123]]
    ];
    if (_displayName isEqualTo "REPORT") then {
        [format["%1 invalid vehicle, weapon or magazine class", _class], 1] call EFUNC(tools,3DENNotification);
        continue;
    };

    private _row = _grp2_list lnbAddRow [_displayName, str _amount];
    _grp2_list lnbSetData [[_row, 0], _class];
    _grp2_list lnbSetPicture [[_row, 0], _icon];
};
_grp2_list lnbSort [0, true];

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: building LIST_2 with inventory: %2", __FILE_NAME__, _inventory], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

