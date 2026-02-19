#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_spawn

Description:
    Handles AI units spawn with a set or random timer

Parameters:
    _logic - [Object]
    _side - [Side]
	_timeout - [Number]
	_format - [String]
    _waves - [Array]:
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
    [getPosASL waves_spawn, east, 120, [
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
 ["_logic", objNull, [objNull]], 
 ["_side", east, [east]],
 ["_timeout", 60, [123]],
 ["_formation", "COLUMN", [""]],
 ["_waves", [], [[]]] 
]; 
 
if(isNull _logic) exitWith { 
	[["% 1: _logic is null", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
}; 
if(_waves isEqualTo []) exitWith {
	[["%1: _waves is empty", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
}; 
 

[_logic, _side, _timeout, _formation, _waves] spawn {
 params["_logic", "_side", "_timeout", "_formation", "_waves"]; 
 
	private _units = [];
	{ 
		private _time = CBA_missionTime + _timeout;
		private _threshold = (count _units) - (floor((count _units) * 0.75)); 
		 
		waitUntil { 
			sleep 5;
            #ifdef BTC_DEBUG_TOOLS
			[["% 1: %2 - time remaining: %3", __FILE_NAME__, _logic, _time - CBA_missionTime], REPORT, "enemy_waves"] call EFUNC(tools,debug);
			[["% 1: %2 - units remaining: %3 threshold: %4", __FILE_NAME__, _logic, count _units, _threshold], REPORT, "enemy_waves"] call EFUNC(tools,debug);
            #endif  
			(CBA_missionTime > _time) ||   
			((count _units) <= _threshold) 
		}; 
 
		private _wave = _x;
        #ifdef BTC_DEBUG_TOOLS
		[["% 1: %2 - Spawning wave: %3", __FILE_NAME__, _logic, _forEachIndex + 1], REPORT, "enemy_waves"] call EFUNC(tools,debug);
        #endif
		_wave apply {//wave 
			private _group = _x; 
			private _grp = createGroup[_side, true]; 
			_grp setVariable ["acex_headless_blacklist", true]; 
			 
			_group apply { 
				if(!(_x params [ //class-quantity array 
					["_class", "", [""]], 
					["_quantity", 0, [123]] 
				])) then { 
					[["% 1: invalid _units array: %2", __FILE_NAME__, _x], REPORT, "enemy_waves"] call EFUNC(tools,debug);
					continue; 
				}; 
 
				if(!(isClass (configFile >> "CfgVehicles" >> _class))) then { 
					[["% 1: %2 is not a valid class", __FILE_NAME__, _class], REPORT, "enemy_waves"] call EFUNC(tools,debug);
					continue; 
				}; 
 
				for "_j" from 1 to _quantity do { 
					private _unit = _grp createUnit [_class, [_logic, 1] call CBA_fnc_randPos, [], 0, "NONE"]; 
					_units pushBack _unit;
					_unit setVariable[QGVAR(wave_spawn), _logic]; 
 
					_unit addEventHandler["Killed", { 
						params ["_unit"];
						private _logic = _unit getVariable[QGVAR(wave_spawn), objNull];
						private _units = _logic getVariable[QGVAR(wave_units), []];
						private _index = _units find _unit; 
						_units deleteAt _index;
						#ifdef BTC_DEBUG_TOOLS
						[["% 1: Removing %2(%3) from %4", __FILE_NAME__, _unit, _logic, _units], LOGS, "enemy_waves"] call EFUNC(tools,debug);
						#endif
						_logic setVariable[QGVAR(wave_units), _units];
					}]; 
					_unit addEventHandler["Deleted", { 
						params ["_unit"]; 
						private _logic = _unit getVariable[QGVAR(wave_spawn), objNull];
						private _units = _logic getVariable[QGVAR(wave_units), []];
						private _index = _units find _unit; 
						_units deleteAt _index;
						#ifdef BTC_DEBUG_TOOLS
							[["% 1: Removing %2(%3) from %4", __FILE_NAME__, _unit, _logic, _units], LOGS, "enemy_waves"] call EFUNC(tools,debug);
						#endif
						_logic setVariable[QGVAR(wave_units), _units];
					}]; 
					sleep 0.5; 
				};

				_logic setVariable[QGVAR(wave_units), _units];
				#ifdef BTC_DEBUG_TOOLS
				[["%1: %2 now holds %3 units", __FILE_NAME__, _logic, count _units], 3, "enemy_waves"] call EFUNC(tools,debug);
				#endif
				 
			};
            #ifndef BTC_DEBUG_TOOLS
			private _players = (allPlayers select {alive _x}) - entities "HeadlessClient_F";
            #else
			private _players = allGroups select {side _x == west};
            #endif
			private _playerLeaders = [];
			_players apply {_playerLeaders pushBackUnique leader _x;};
			_playerLeaders = [_playerLeaders, [_logic], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;
			private _leader = _playerLeaders select 0;
			
            #ifdef BTC_DEBUG_TOOLS
			[["%1: %2 heading for: %3", __FILE_NAME__, _grp, _leader], 3, "enemy_waves"] call EFUNC(tools,debug);
            #endif
			private _wp = _grp addWaypoint [getPosASL _leader, -1];  
			_wp setWaypointBehaviour "AWARE"; 
			_wp setWaypointCombatMode "YELLOW"; 
			_wp setWaypointFormation _formation; 
			_wp setWaypointSpeed "FULL"; 
		}; 
 
	}forEach _waves; 
};
