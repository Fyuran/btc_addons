#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_animation_in_client

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] spawn btc_bridge_animation_in_client;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
    ["_segment", objNull, [objNull]]
];
if(isNull _vehicle) exitWith {
	[["%1: vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(isNull _segment) exitWith {
	[["%1: _segment is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!canSuspend) exitWith {
	[["%1: executed in non suspendable environment", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Attempted by !hasInterface", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(!local _segment) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Attempted to animate a non local _segment", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

if(isRemoteExecutedJIP) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: animation_in JIP", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	deleteVehicle _segment;
};
#ifdef BTC_DEBUG_BRIDGE
[["%1: animation_in on client", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

_segment setPhysicsCollisionFlag false;
[_vehicle, true] call FUNC_C(setIsAnimating);

//audio
[_segment, _vehicle] spawn {
	params["_segment", "_vehicle"];
	playSound3D[QPATHTOF(data\hydraulic_start.ogg), _segment, false, getPosASL _segment, 1, 1, 0, 0, true];
	sleep 0.750;
	while{[_vehicle getVariable[QGVAR(isAnimating), false], false] select (isNull _vehicle)} do {
		playSound3D[QPATHTOF(data\hydraulic_loop.ogg), _segment, false, getPosASL _segment, 1, 1, 0, 0, true];
		sleep 0.991;
	};
	playSound3D[QPATHTOF(data\hydraulic_end.ogg), _segment, false, getPosASL _segment, 1, 1, 0, 0, true];
};

//Back of the truck
private _forward = (vectorNormalized(vectorDir _vehicle)) vectorMultiply -1;
_forward = [_forward#0, _forward#1, 0]; //flat

private _vehicle_posASL = getPosASL _vehicle;
private _front_start_posASL = _vehicle_posASL vectorAdd (_forward vectorMultiply FRONT_OFFSET_MULTIPLIER);
_front_start_posASL = _front_start_posASL vectorAdd [0, 0, -0.2]; //lower it a bit

//Step 0 close the damn thing if it's open
if((_segment animationSourcePhase "fold_source") < 1) then {
	_segment animateSource ["fold_source", 1];
	playSound3D[QPATHTOF(data\fold_source.ogg), _segment, false, getPosASL _segment, 1, 1, 0, 0, true];
};

//Step 1 reach front
private _segments = _vehicle getVariable[QGVAR(segments), []];
private _previous = if(_segments isNotEqualTo []) then {
	_segments select -1;
} else {
	_vehicle;
};
private _posASL = getPosASL _segment;

private _step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime);
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _front_start_posASL, true];
    _segment setPosASL _newPosASL;	
};

//Step 2 increase height
_posASL = getPosASL _segment;
private _toPosASL = _posASL vectorAdd [0, 0, 2.8];
_step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime);
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _toPosASL, true];
    _segment setPosASL _newPosASL;
};

//Step 3 move backwards
private _posASL = getPosASL _segment;
private _toPosASL = _vehicle modelToWorldWorld DECO_OFFSET;
_toPosASL set [2, _posASL#2]; //same height

_step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime);    
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _toPosASL, true];
    _segment setPosASL _newPosASL;
};

//Step 4
[_vehicle, false] call FUNC_C(setIsAnimating);
deleteVehicle _segment;
