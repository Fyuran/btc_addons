#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_spawn_begin

Description:
    Spawns configured waves of enemy groups at module position according to timeout intervals and assigned formation.
    Array structure is as follows:
	[GROUPS
		[ GROUP
			["UNIQUE_CLASS_STRING_1", NUMBER], ["UNIQUE_CLASS_STRING_2", NUMBER...
		],
		[
			["UNIQUE_CLASS_STRING_1", NUMBER], ["UNIQUE_CLASS_STRING_2", NUMBER]...
		]
	]

Parameters:
    _logic: OBJECT - Enemy waves logic module

Returns:

Examples:
    (begin example)
        [_logic] call btc_toolchain_enemy_waves_fnc_spawn_begin;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[ 
	["_logic", objNull, [objNull]]
]; 
 
if(isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: Should be run only on Server", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (!canSuspend) exitWith {
	_this spawn FUNC(spawn_begin);
};

private _logicGroups = _logic getVariable [QGVAR(list_value), ""];
if(_logicGroups isEqualTo "") exitWith {
	[["%1: bad _logicGroups has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_logicGroups = fromJSON _logicGroups;
if (_logicGroups isEqualTo []) exitWith {
	[["%1: bad _logicGroups has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
 
private _timeout = _logic getVariable[QGVAR(timeout), 60];
private _side = (_logic getVariable[QGVAR(side), east]) call BIS_fnc_sideType;
private _units = [];

_logicGroups apply {
	private _logicGroup = _x;
	private _time = CBA_missionTime + _timeout;
	private _threshold = ((count _units) - (floor((count _units) * 0.75))) max 0; 
		
	waitUntil { 
		#ifdef BTC_DEBUG_ENEMY_WAVES
		[["%1: %2(Group %3) - time remaining: %4", __FILE_NAME__, _logic, _logicGroup, _time - CBA_missionTime], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		[["%1: %2(Group %3) - units remaining: %4 threshold: %5", __FILE_NAME__, _logic, _logicGroup, count _units, _threshold], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		#endif
		sleep 5;
		(CBA_missionTime > _time) || ((count _units) <= _threshold)
	}; 

	if(isNull _logic) exitWith {
		[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};

	private _group = createGroup[_side, true];
	_group setVariable ["acex_headless_blacklist", true]; 

	#ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: %2 - Spawning wave: %3", __FILE_NAME__, _logic, _logicGroup], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif

	_logicGroup apply { //wave's classes hashmap
		_x params [
			["_class", "", [""]], 
			["_quantity", 1, [123]] 
		]; 

		if(!(isClass (configFile >> "CfgVehicles" >> _class))) then { 
			[["%1: %2 is not a valid class", __FILE_NAME__, _class], REPORT, QCOMPONENT] call EFUNC(tools,debug);
			continue; 
		}; 
		
		for "_i" from 1 to _quantity do { 
			private _unit = objNull;
			private _randSpawnPos = [_logic, _class] call EFUNC(tools,findSafePos);
			if ([_class, "CAManBase"] call EFUNC(tools,inheritsFromAny)) then {
				_unit = _group createUnit [_class, _randSpawnPos, [], 0, "NONE"]; 
			} else {
				if ([_class, ["LandVehicle", "Air"]] call EFUNC(tools,inheritsFromAny)) then {
					_unit = ([_randSpawnPos, 0, _class, _group] call BIS_fnc_spawnVehicle) select 0; //returns Array [createdVehicle, crew, group]:
				};
			};
			
			if (isNull _unit) then {
				continue;
			};

			_units pushBack _unit;
			_unit setVariable[QGVAR(wave_spawn), _logic]; 

			sleep 0.5; 
		};
	}; 

	_logic setVariable[QGVAR(wave_units), _units];
	#ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: %2 now holds %3 units", __FILE_NAME__, _logic, count _units], 3, QCOMPONENT] call EFUNC(tools,debug);
	#endif

	allCurators apply {
		_x addCuratorEditableObjects [_units, true];
	};

	[_units] call FUNC(spawn_addEH);
	[_logic, _group] call FUNC(wp_moduleInit);
};
