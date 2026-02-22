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
    ["_value", "", ["", createHashMap]]
];
disableSerialization;

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing attribute load with _value: %2", __FILE_NAME__, _value], CHAT, "supply"] call EFUNC(tools,debug);
#endif
if(_value isEqualTo "") exitWith {};
if(_value isEqualTo createHashMap) exitWith {};
if(_value isEqualType "") then {
    GVAR(table) = fromJSON _value;
} else {
    GVAR(table) = +_value;
};

//Group 1
private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
if((ctrlIDC _grp1) isNotEqualTo GROUP_1) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp1, GROUP_1], REPORT, "supply"] call EFUNC(tools,debug);
};
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;
lbClear _grp1_list;
/*
    HashMap structure is as follows:
        "vehicle": STRING
        "allowDamage": BOOL
        "CLASS-diag_tickTime-hashedChars": HashMap
            "class": STRING
            "inventory": HashMap
                "CFG_CLASS_1": SCALAR
                "CFG_CLASS_2": SCALAR
                ...
    LIST_2 entries will be created at runtime by hashmap lookup
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
            [["%1 invalid ammo box or vehicle class", _class], REPORT, "supply"] call EFUNC(tools,debug);
            continue;
        };

        private _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));
        //_grp1_list lbSetPicture [_row, getText (_cfg >> "icon")];
        _grp1_list lbSetData [_row, _uid];
    };
};
