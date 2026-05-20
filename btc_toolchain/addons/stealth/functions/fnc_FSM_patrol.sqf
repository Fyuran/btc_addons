#include "..\script_component.hpp"

[
_this, 
{
	/*STATE*/
	params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};

	private _hasFound = false;
	(units _group) apply {
		private _bodies = [side _group] call FUNC(getAllSideCorpses);
		private _entity = [_x, allPlayers + _bodies] call FUNC(unitDetectEntities);
		if(!isNull _entity) then {
			private _threat_dis = _group getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
			
			private _rate = 1/5 + (1/8 - 1/5) * (((_x distance _entity) - MIN_DIS) / (_threat_dis - MIN_DIS));
			private _varName = ["threat", "body_threat"] select (_entity in _bodies);
			if(_entity in _bodies) then {
				[_group, 0.5, _varName] call FUNC(addThreat);
				[_group, _entity, 0] call FUNC(setLastKnownPosition);
			} else {
				[_group, _rate, _varName] call FUNC(addThreat);
				[_group, _entity, 2] call FUNC(setLastKnownPosition);
			};
			_hasFound = true;
		};
	};

	if(!_hasFound) then {
		[_group, -1/80] call FUNC(addThreat);
	};

}, {
    /*ENTER*/
    params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};
	
	private _original_WPS = _group getVariable[QGVAR(Original_WPS), []];
	if(_original_WPS isEqualTo []) then {
		_group setVariable [QGVAR(Original_WPS), [_group] call FUNC(getWaypoints)];
	} else {
		[_group, _original_WPS] call FUNC(setWaypoints);
	};

	(units _group) apply {
		_x disableAI "RADIOPROTOCOL";
	};
	allPlayers apply {
		_group forgetTarget _x;
	};
	
	_group setCombatMode "BLUE";
	_group setBehaviourStrong "CARELESS";
    _group setSpeedMode "LIMITED";

}, {
	/*EXIT*/
    params[["_group", grpNull, [grpNull]]];

	_group setVariable [QGVAR(Original_WPS), [_group] call FUNC(getWaypoints)];

}, "Patrol"]
