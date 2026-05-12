#include "..\script_component.hpp"

params[
    ["_unit", objNull, [objNull]]
];

private _group = group _unit;
private _alarm_dis = _group getVariable[QGVAR(alarm_distance), ALARM_DISTANCE];
(allDeadMen select {(_x distance (getPos _unit) <= _alarm_dis)}) apply {
    [_x, false] call FUNC(dispatchBody);
};

if(GVAR(radioInProgress)) exitWith {};

if(!canSuspend) exitWith {
    _this spawn FUNC(call_removeReinforcements);
};
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
if(!local _unit) exitWith {
	[["%1: _unit is not local", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};

GVAR(radioInProgress) = true;
//delay further radio calls
[{
    GVAR(radioInProgress) = false;
}, [], _group getVariable[QGVAR(radio_delay), 60]] call CBA_fnc_waitAndExecute;

doStop _unit;
_unit disableAI "ANIM";
_unit disableAI "RADIOPROTOCOL";
_unit switchMove "Acts_listeningToRadio_In";

private _soundName = format[QGVAR(hq_call_%1), selectRandom [1, 2, 3, 4]];
[_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
sleep 1;
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
_unit switchMove "Acts_listeningToRadio_Loop";
_soundName = format[QGVAR(all_clear_%1), selectRandom [1, 2, 3, 4]];
[_unit, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];
sleep 2;
if(!alive _unit || {IS_UNCONSCIOUS}) exitWith {};
_unit switchMove "Acts_listeningToRadio_Out";

//radio request call off reinforcements
private _nearGrps = [_unit, _alarm_dis, [], {
    params[
        ["_grp", grpNull, [grpNull]]
    ];

    [_grp, 0] call FUNC(setThreat);
	[_grp, 0, "body_threat"] call FUNC(setThreat);
    _grp setVariable[QGVAR(isReinforcement), false];

    #ifdef BTC_DEBUG_STEALTH
    [["%1: %2 has been called off", __FILE_NAME__, _grp], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug); 
    #endif
}] call FUNC(execNearbyGrps);

_unit enableAI "ANIM";
_unit doFollow leader _group;
sleep 0.1;
_unit enableAI "RADIOPROTOCOL";
