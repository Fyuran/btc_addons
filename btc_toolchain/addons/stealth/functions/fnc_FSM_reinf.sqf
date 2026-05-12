#include "..\script_component.hpp"

[
_this, 
{
	/*STATE*/
	params[["_group", grpNull, [grpNull]]];
	if(isNull _group) exitWith {
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
			[_group, _player, 5] call FUNC(setLastKnownPosition);
		};
	};
}, {
    /*ENTER*/
    params[["_group", grpNull, [grpNull]]];

	_group setBehaviourStrong "AWARE";

	private _reinf_location = _group getVariable[QGVAR(reinf_location), [0, 0, 0]];
	if(_reinf_location isEqualTo [0, 0, 0]) exitWith {
		[["%1: %2 could not reinforce as reinf_location is invalid", __FILE_NAME__, _group], REPORT, QCOMPONENT] call EFUNC(tools,debug); 
		_group setVariable[QGVAR(isReinforcement), false];
	};
	[_group, _group getVariable [QGVAR(investigate_threshold), 1]] call FUNC(setThreat);
	[_group, [[0, _reinf_location, 25, "MOVE", "UNCHANGED", "UNCHANGED", 
		"FULL", "NO CHANGE", ["true", ""], [0, 0, 0]]]] call FUNC(setWaypoints);

}, {/*EXIT*/}, "Reinforcement"]
