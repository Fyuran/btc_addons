#include "..\script_component.hpp"

params[
    ["_unit", objNull, [objNull]],
    ["_flag", INTRUDER, [123]]
];

if(GVAR(radioInProgress)) exitWith {};

if(!canSuspend) exitWith {
    _this spawn FUNC(call_reinforcements);
};

if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
if(!local _unit) exitWith {
	[["%1: _unit is not local", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};
GVAR(radioInProgress) = true;
//delay further radio calls
private _group = group _unit;
[{
    GVAR(radioInProgress) = false;
}, [], _group getVariable[QGVAR(radio_delay), 10]] call CBA_fnc_waitAndExecute;

doStop _unit;
_unit disableAI "ANIM";
_unit disableAI "RADIOPROTOCOL";
_unit switchMove "Acts_listeningToRadio_In";

private _soundName = format[QGVAR(hq_call_%1), selectRandom [1, 2, 3, 4]];
[_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];

if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
_soundName = switch(_flag) do {
    case INTRUDER: {
        format[QGVAR(request_reinf_%1), selectRandom [1, 2, 3, 4]];
    };
    case BODY: {
        format[QGVAR(hq_body_%1), selectRandom [1, 2, 3, 4, 5]];
    };
    default {
        [["%1: wrong _flag passed: %2", __FILE_NAME__, _flag], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
};
[_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];

sleep 1;
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
_unit switchMove "Acts_listeningToRadio_Loop";
sleep 3;
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
sleep 3;
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
_unit switchMove "Acts_listeningToRadio_Out";

//radio request reinforcements
private _alarm_dis = _group getVariable[QGVAR(alarm_distance), ALARM_DISTANCE];
private _lastKnownPos = _group getVariable[QGVAR(lastKnownPos), [0, 0, 0]];
private _nearGrps = [_unit, _alarm_dis, [_lastKnownPos], {
    params[
        ["_grp", grpNull, [grpNull]],
        ["_args", [], [[]]]
    ];
    _args params[
        ["_lastKnownPos", [0, 0, 0], [[]], 3]
    ];
    if(_lastKnownPos isEqualTo [0, 0, 0]) exitWith {};
    if(_grp getVariable[QGVAR(isReinforcement), false]) exitWith {};
    #ifdef BTC_DEBUG_STEALTH
    [["%1: %2 is reinforcing to %3", __FILE_NAME__, _grp, _lastKnownPos], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug); 
    #endif
    _grp setVariable[QGVAR(isReinforcement), true];
    _grp setVariable[QGVAR(reinf_location), _lastKnownPos];
}] call FUNC(execNearbyGrps);

if(!alive _unit) exitWith {
    _soundName = format[QGVAR(hq_mia_%1), selectRandom [3, 4, 5]];
    [_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
    GVAR(radioInProgress) = false;
};

if(_nearGrps isNotEqualTo []) then {
    _soundName = format[QGVAR(hq_accept_reinf_%1), selectRandom [1, 2, 3]];
    [_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
} else {
    [_unit, QGVAR(hq_refuse_1)] remoteExecCall["say3D", [0, -2] select isDedicated];
};

_unit enableAI "ANIM";
_unit doFollow leader _group;
sleep 0.1;
_unit enableAI "RADIOPROTOCOL";
