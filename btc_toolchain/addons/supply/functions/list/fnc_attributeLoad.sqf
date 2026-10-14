#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_attributeLoad

Description:
    Populates supply list controls from JSON or hashmap data and syncs UI.

Parameters:
    _main_grp: CONTROL or ARRAY - Main control group containing list displays
    _value: STRING or HASHMAP - JSON string or hashmap containing supply data

Returns:
    NOTHING

Examples:
    (begin example)
        [_mainGroup, _supplyData] call btc_toolchain_supply_fnc_list_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]],
    ["_value", createHashMap, []]
];

if (!(_value isEqualTypeAny ["", createHashMap])) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
	[["%1: _value(%2):%3 not STRING or HASHMAP", __FILE_NAME__, typeName _value, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};
disableSerialization;

#ifdef BTC_DEBUG_SUPPLY
[["%1: executing list load with _value: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if(_value isEqualTo "") exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: empty _value as STRING", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
if(_value isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: empty _value as HASHMAP", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
if(_value isEqualType "") then {
    GVAR(table) = fromJSON _value;
} else {
    GVAR(table) = +_value;
};
if(GVAR(table) isEqualTo createHashMap) exitWith { //check again after parsing
	#ifdef BTC_DEBUG_SUPPLY
	[["%1: GVAR(table) is an empty hashmap", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};

//Group 1
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;
lbClear _grp1_list;

//Group 2
private _grp2 = _main_grp controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
lnbClear _grp2_list;
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

GVAR(table) apply {
    [_x, _y] params [
        ["_uid", "", [""]],
        ["_inner", createHashMap, [createHashMap]]
    ];

    private _class = _inner get "class";
    private _cfg = configFile >> "CfgVehicles" >> _class;
    if(!isClass _cfg) then {
        [["%1: invalid ammo box or vehicle class", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        continue;
    };

    private _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));
    //_grp1_list lbSetPicture [_row, getText (_cfg >> "icon")];
    _grp1_list lbSetData [_row, _uid];
};
lbSort _grp1_list;

