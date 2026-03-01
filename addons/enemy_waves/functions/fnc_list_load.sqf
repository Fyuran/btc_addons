#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_list_load

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_list_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]],
    ["_value", [], ["", []]]
];
disableSerialization;

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing list load with _value: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if(_value isEqualType "") then {
	_value = parseSimpleArray _value;
};
if(_value isEqualTo []) exitWith {
	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: _value is empty", __FILE_NAME__, GVAR(table)], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};
GVAR(table) = +_value;

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
    LIST_2 entries will be created at runtime by hashmap lookup
*/
if(GVAR(table) isNotEqualTo []) then {
	//Group 1
	private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
	private _grp1_list = _grp1 controlsGroupCtrl LIST_1;
	lbClear _grp1_list;
	
    private _grp2 = _main_grp controlsGroupCtrl GROUP_2;
    private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    lnbClear _grp2_list;

	for "_i" from 1 to (count GVAR(table)) do {
		_grp1_list lbAdd (format["Group %1", _i]);
	};
};
