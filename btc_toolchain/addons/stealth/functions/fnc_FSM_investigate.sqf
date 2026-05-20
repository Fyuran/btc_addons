#include "..\script_component.hpp"

[
_this,
{
	/*State*/
	params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};

	private _hasFound = false;
	(units _group) apply {
		private _player = [_x, allPlayers] call FUNC(unitDetectEntities);
		if(!isNull _player) then {
			private _threat_dis = _group getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
			private _rate = 1/5 + (1/8 - 1/5) * (((_x distance _player) - MIN_DIS) / (_threat_dis - MIN_DIS));
			[_group, _rate] call FUNC(addThreat);
			[_group, _player, 0] call FUNC(setLastKnownPosition);
			_hasFound = true;
		};
	};
	if(!_hasFound) then {
		[_group, -1/80] call FUNC(addThreat);
	};
}, {
	/*Enter*/
	params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};
	
	(units _group) apply {
		_x enableAI "ALL";
	};
	private _lastKnownPos = _group getVariable[QGVAR(lastKnownPos), [0, 0, 0]];
    _group setSpeedMode "FULL";
	_group setBehaviourStrong "AWARE";
	_group setCombatMode "GREEN";

	if (_lastKnownPos isNotEqualTo [0, 0, 0]) then {
		[_group, [[0, _lastKnownPos, 5]]] call FUNC(setWaypoints);
	};

}, {/*Exit*/}, "Investigate"]
