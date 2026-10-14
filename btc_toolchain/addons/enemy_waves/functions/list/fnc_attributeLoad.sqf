#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_attributeLoad

Description:
    Loads wave composition data into the dialog controls and populates group list entries.

Parameters:
    _main_grp: CONTROL
    _value: ARRAY/STRING

Returns:

Examples:
    (begin example)
        [_mainGroupControl, _savedData] call btc_toolchain_enemy_waves_fnc_list_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]],
    ["_value", createHashMap, []]
];

if (!(_value isEqualTypeAny ["", createHashMap])) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _value(%2):%3 not STRING or HASHMAP", __FILE_NAME__, typeName _value, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};
disableSerialization;

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing list load with _value: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if(_value isEqualTo "") exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: empty _value as STRING", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
if(_value isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
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

/*
    Array structure is as follows:
		[
			[
				["CLASS_1", 1], ["CLASS_2", 1]...
			],
			[
				["CLASS_1", 1], ["CLASS_2", 1]...
			]
		]
    LIST_2 entries will be created onlbSelChanged at runtime by hashmap lookup
*/

//Group 1
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;
lbClear _grp1_list;

private _grp2 = _main_grp controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
lnbClear _grp2_list;

for "_i" from 1 to (count GVAR(table)) do {
	_grp1_list lbAdd (format["Group %1", _i]);
};

