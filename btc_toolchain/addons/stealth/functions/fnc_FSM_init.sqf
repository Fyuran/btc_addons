#include "..\script_component.hpp"

params[
	["_FSM", locationNull, [locationNull]]
];
if(isNull _FSM) exitWith {};

private _patrol = (_FSM call FUNC(FSM_patrol)) call CBA_statemachine_fnc_addState;
private _investigate = (_FSM call FUNC(FSM_investigate)) call CBA_statemachine_fnc_addState;
private _investigate_body = (_FSM call FUNC(FSM_investigate_body)) call CBA_statemachine_fnc_addState;
private _alert = (_FSM call FUNC(FSM_alert)) call CBA_statemachine_fnc_addState;
private _cover = (_FSM call FUNC(FSM_cover)) call CBA_statemachine_fnc_addState;
private _reinforcement = (_FSM call FUNC(FSM_reinf)) call CBA_statemachine_fnc_addState;

[_FSM, _patrol, _investigate, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	_threat >= (_group getVariable [QGVAR(investigate_threshold), 1])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	(units _group) spawn {
		_this apply {
			sleep random 1;
			private _soundName = format[QGVAR(investigate_%1), selectRandom [1, 2, 3, 4, 5]];
			[_x, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
		};
	};
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _patrol, _investigate_body, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _body_threat = _group getVariable[QGVAR(body_threat), 0];
	_body_threat >= (_group getVariable [QGVAR(investigate_threshold), 1])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	(units _group) spawn {
		_this apply {
			sleep random 1;
			private _soundName = format[QGVAR(investigate_%1), selectRandom [1, 2, 3, 4, 5]];
			[_x, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
		};
	};
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with body_threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(body_threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _investigate_body, _reinforcement, {
	params[
		["_group", grpNull, [grpNull]]
	];
	_group getVariable[QGVAR(isReinforcement), false]
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with isReinforcement: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(isReinforcement), false]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _patrol, _reinforcement, {
	params[
		["_group", grpNull, [grpNull]]
	];
	_group getVariable[QGVAR(isReinforcement), false]
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with isReinforcement: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(isReinforcement), false]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _reinforcement, _patrol, {
	params[
		["_group", grpNull, [grpNull]]
	];
	!(_group getVariable[QGVAR(isReinforcement), false])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with isReinforcement: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(isReinforcement), false]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _investigate, _reinforcement, {
	params[
		["_group", grpNull, [grpNull]]
	];
	_group getVariable[QGVAR(isReinforcement), false]
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with isReinforcement: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(isReinforcement), false]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _investigate, _patrol, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	_threat < (_group getVariable [QGVAR(investigate_threshold), 1])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _investigate, _cover, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	_threat >= (_group getVariable [QGVAR(cover_threshold), 2])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _cover, _alert, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	private _groupInCover = true;
	(units _group) apply {
		if(!(_x getVariable[QGVAR(isInCover), false])) then {
			_groupInCover = false;
			break;
		};
	};
	_groupInCover && 
	{_threat >= (_group getVariable [QGVAR(alarm_threshold), 3])}
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _investigate_body, _alert, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];

	_group getVariable[QGVAR(body_dispatched), false] ||
	_threat >= (_group getVariable [QGVAR(cover_threshold), 2])

}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with body_threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(body_threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _reinforcement, _alert, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	private _distance = (_group getVariable[QGVAR(reinf_location), [0, 0, 0]]) distance (leader _group);
	_threat > (_group getVariable [QGVAR(cover_threshold), 2]) ||
	_distance <= 50
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;

[_FSM, _alert, _patrol, {
	params[
		["_group", grpNull, [grpNull]]
	];
	private _threat = _group getVariable[QGVAR(threat), 0];
	_threat <= (_group getVariable [QGVAR(alarm_threshold), 3])
}, {
	params[
		["_group", grpNull, [grpNull]]
	];
	[_group, 0] call FUNC(setThreat);

	#ifdef BTC_DEBUG_STEALTH
	[["%1: %2 transitioned from %3 to %4 with threat: %5", __FILE_NAME__,
		_this, _thisOrigin, _thisTarget, _this getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}] call CBA_statemachine_fnc_addTransition;
