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

	(units _group) apply {
		private _player = [_x, allPlayers] call FUNC(unitDetectEntities);
		if(!isNull _player) then {
			private _threat_dis = _group getVariable[QGVAR(threat_distance), THREAT_DISTANCE];

			private _rate = 1/5 + (1/8 - 1/5) * (((_x distance _entity) - MIN_DIS) / (_threat_dis - MIN_DIS));
			[_group, _rate] call FUNC(addThreat);
			[_group, _player, 0] call FUNC(setLastKnownPosition);
		};
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
		[_group, [[0, _lastKnownPos, -1, "MOVE", "UNCHANGED", "UNCHANGED", 
			"UNCHANGED", "NO CHANGE", ["true", ""], [0, 0, 0]]]] call FUNC(setWaypoints);
	};

    [leader _group, _lastKnownPos] spawn {
		params["_unit", "_pos"];
		private _time = CBA_missionTime + 30; //timeout
		waitUntil{((_unit distance _pos) <= 1) || (CBA_missionTime > _time)};
		
		[_unit, BODY] call FUNC(call_reinforcements);
		if(!alive _unit) exitWith {};
		if(CBA_missionTime > _time) exitWith {}; //abort body removal when timing out
		private _threat_dis = (group _unit) getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
		(allDeadMen select {(_x distance _pos <= (_threat_dis / 2))}) apply {
			[_x] call FUNC(dispatchBody);
		};
		(group _unit) setVariable[QGVAR(body_dispatched), true];
	};

}, {
	/*Exit*/
	params[["_group", grpNull, [grpNull]]];
	_group setVariable[QGVAR(body_dispatched), false];
	[_group, 0, "body_threat"] call FUNC(setThreat);
}, "Investigate_Body"]
