#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_list_load

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_list_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]],
    ["_value", "", [""]]
];
disableSerialization;

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing attribute load with _value: %2", __FILE__, _value], 2, "supply"] call EFUNC(tools,debug);
#endif
if(_value isEqualTo "") exitWith {};

GVAR(table) = fromJSON _value;

//Group 1
private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
if((ctrlIDC _grp1) isNotEqualTo GROUP_1) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE__, ctrlIDC _grp1, GROUP_1], 6, "supply"] call EFUNC(tools,debug);
};
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

/*
    HashMap structure is as follows:
        "CLASS-diag_tickTime-hashedChars": HashMap
            "class": STRING
            "inventory": HashMap
                "CFG_CLASS_1": SCALAR
                "CFG_CLASS_2": SCALAR
                ...
*/
if(GVAR(table) isNotEqualTo createHashMap) then {
    GVAR(table) apply {
        [_x, _y] params [
            ["_uid", "", [""]],
            ["_inner", createHashMap, [createHashMap]]
        ];

        private _class = _inner get "class";
        private _cfg = configFile >> "CfgVehicles" >> _class;
        if(!isClass _cfg) then {
            [["%1 invalid ammo box or vehicle class", _class], 6, "supply"] call EFUNC(tools,debug);
            continue;
        };

        private _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));
        _grp1_list lbSetPicture [_row, getText (_cfg >> "icon")];
        _grp1_list lbSetData [_row, _uid];

        private _inventory = _inner get "inventory";
    };
};
