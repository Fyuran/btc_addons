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

	private _hasFound = false;
	(units _group) apply {
		private _player = [_x, allPlayers, 300] call FUNC(unitDetectEntities);
		if(!isNull _player) then {
			[_group, _player, 0] call FUNC(setLastKnownPosition);
			private _threat_limit = _group getVariable[QGVAR(threat_limit), 4];
			[_group, _threat_limit] call FUNC(setThreat);
			_hasFound = true;
		};
	};
	if(!_hasFound) then {
		[_group, -1/150] call FUNC(addThreat);
	};
}, 
{
	/*ENTER*/
	params[["_group", grpNull, [grpNull]]];

	private _threat_limit = _group getVariable[QGVAR(threat_limit), 4];
	[_group, _threat_limit] call FUNC(setThreat);

	(units _group) apply {
        _x enableAI "RADIOPROTOCOL";
    	_x doFollow leader _group; //release units from doStop
	};
	_group setBehaviourStrong "COMBAT";
	_group setCombatMode "RED";

	private _lastKnownPos = _group getVariable[QGVAR(lastKnownPos), [0, 0, 0]];
	if (_lastKnownPos isNotEqualTo [0, 0, 0]) then {
		[_group, _lastKnownPos, 50, true] call CBA_fnc_taskAttack;
	} else {
		[_group, getPos(leader _group), 50, true] call CBA_fnc_taskAttack;
	};

}, {/*EXIT*/
	params[["_group", grpNull, [grpNull]]];
	[leader _group] call FUNC(call_removeReinforcements);
	_group setVariable[QGVAR(isReinforcement), false];
}, "Alert"];
