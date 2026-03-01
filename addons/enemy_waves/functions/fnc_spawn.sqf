#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_spawn

Description:
    Handles AI units spawn with a set or random timer

Parameters:
    _logic - [Object]
    _side - [Side]
	_timeout - [Number]
	_formation - [String]
    _groups - [Array]:
    [
        WaveN:
        [
            GrpN:
            [
                [Class1, Quantity1], [Class2, Quantity2]
            ]
        ]
    ]
Returns:

Examples:
    (begin example)
    [waves_spawn, east, 120, [
        [
            [
                ["O_Soldier_A_F", 3],["O_soldierU_AT_F", 2]
            ]
        ],
        [
            [
                ["O_Soldier_A_F", 1],["O_soldierU_AT_F", 1]
            ]
        ]
    ]] call btc_enemy_waves_fnc_spawn;
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

private _side = (_logic getVariable[QGVAR(side), east]) call BIS_fnc_sideType;
private _timeout = _logic getVariable[QGVAR(timeout), 60];
private _formation = _logic getVariable[QGVAR(formation), "COLUMN"];
private _groups = _logic getVariable[QGVAR(list), []];
if(_groups isEqualType "") then { //module config sets the value as STRING
	_groups = parseSimpleArray _groups;
};
if(_groups isEqualTo []) exitWith {
	[["%1: _groups is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
}; 
 
/*
    Array structure is as follows:
		[GROUPS
			[ GROUP
				["CLASS_1", 1], ["CLASS_2", 1]...
			],
			[
				["CLASS_1", 1], ["CLASS_2", 1]...
			]
		]
*/
[_logic, _side, _timeout, _formation, _groups] spawn {
	params[
		["_logic", objNull, [objNull]], 
		["_side", east, [east]], 
		["_timeout", 60, [123]], 
		["_formation", "COLUMN", [""]], 
		["_groups", [], [[]]]
	]; 

	private _units = [];
	_groups apply {
		private _group = _x;
		private _time = CBA_missionTime + _timeout;
		private _threshold = ((count _units) - (floor((count _units) * 0.75))) max 0; 
		 
		waitUntil { 
			sleep 5;
            #ifdef BTC_DEBUG_ENEMY_WAVES
			[["%1: %2(Group %3) - time remaining: %4", __FILE_NAME__, _logic, _group, _time - CBA_missionTime], LOGS, QCOMPONENT] call EFUNC(tools,debug);
			[["%1: %2(Group %3) - units remaining: %4 threshold: %5", __FILE_NAME__, _logic, _group, count _units, _threshold], LOGS, QCOMPONENT] call EFUNC(tools,debug);
            #endif  
			(CBA_missionTime > _time) ||   
			((count _units) <= _threshold) 
		}; 

		if(isNull _logic) exitWith {
			[["%1: _logic has become null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
		};
		private _grp = createGroup[_side, true]; 
		_grp setVariable ["acex_headless_blacklist", true]; 
        #ifdef BTC_DEBUG_ENEMY_WAVES
		[["%1: %2 - Spawning wave: %3", __FILE_NAME__, _logic, _group], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
		_group apply { //wave's classes hashmap
			_x params [
				["_class", "", [""]], 
				["_quantity", 1, [123]] 
			]; 

			if(!(isClass (configFile >> "CfgVehicles" >> _class))) then { 
				[["%1: %2 is not a valid class", __FILE_NAME__, _class], REPORT, QCOMPONENT] call EFUNC(tools,debug);
				continue; 
			}; 
			
			for "_i" from 1 to _quantity do { 
				private _unit = _grp createUnit [_class, [_logic, 1] CBAFUNC(randPos), [], 0, "NONE"]; 
				_units pushBack _unit;
				_unit setVariable[QGVAR(wave_spawn), _logic]; 

				_unit addEventHandler["Killed", { 
					params ["_unit"];
					private _logic = _unit getVariable[QGVAR(wave_spawn), objNull];
					private _units = _logic getVariable[QGVAR(wave_units), []];
					private _index = _units find _unit; 
					_units deleteAt _index;
					#ifdef BTC_DEBUG_ENEMY_WAVES
					[["%1: Removing %2(%3) from %4", __FILE_NAME__, _unit, _logic, _units], LOGS, QCOMPONENT] call EFUNC(tools,debug);
					#endif
					_logic setVariable[QGVAR(wave_units), _units];
				}]; 
				_unit addEventHandler["Deleted", { 
					params ["_unit"]; 
					private _logic = _unit getVariable[QGVAR(wave_spawn), objNull];
					private _units = _logic getVariable[QGVAR(wave_units), []];
					private _index = _units find _unit; 
					_units deleteAt _index;
					#ifdef BTC_DEBUG_ENEMY_WAVES
						[["%1: Removing %2(%3) from %4", __FILE_NAME__, _unit, _logic, _units], LOGS, QCOMPONENT] call EFUNC(tools,debug);
					#endif
					_logic setVariable[QGVAR(wave_units), _units];
				}]; 
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

		#ifndef BTC_DEBUG_ENEMY_WAVES
		private _players = (allPlayers select {alive _x}) - entities "HeadlessClient_F";
		#else
		private _players = allGroups select {side _x == west};
		#endif
		private _playerLeaders = [];
		_players apply {_playerLeaders pushBackUnique leader _x;};
		_playerLeaders = [_playerLeaders, [_logic], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;
		private _leader = _playerLeaders select 0;
		
		#ifdef BTC_DEBUG_ENEMY_WAVES
		[["%1: %2 heading for: %3", __FILE_NAME__, _grp, _leader], 3, QCOMPONENT] call EFUNC(tools,debug);
		#endif
		private _wp = _grp addWaypoint [getPosASL _leader, -1];  
		_wp setWaypointBehaviour "AWARE"; 
		_wp setWaypointCombatMode "YELLOW"; 
		_wp setWaypointFormation _formation; 
		_wp setWaypointSpeed "FULL";
		//Endless hunt
		_wp setWaypointStatements ["true", "
			_players = (allPlayers select {alive _x}) - entities ""HeadlessClient_F"";
			_players apply {_playerLeaders pushBackUnique leader _x;};
			_playerLeaders = [_playerLeaders, [_logic], {_x distance _input0}, ""ASCEND""] call BIS_fnc_sortBy;
			_leader = _playerLeaders select 0;

			_grp = group this;
			_grp addWaypoint [getPosASL _leader, -1]; 
		"];
	};

	deleteVehicle _logic;
};
