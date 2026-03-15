#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_animation_out_client

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] spawn btc_bridge_animation_out_client;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
    ["_segment", objNull, [objNull]],
	["_isEnd", false, [true]]
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
#ifdef BTC_DEBUG_BRIDGE
[["%1: animation_out on client", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

//Back of the truck
private _forward = (vectorNormalized(vectorDir _vehicle)) vectorMultiply -1;
_forward = [_forward#0, _forward#1, 0]; //flat

private _vehicle_posASL = getPosASL _vehicle;
private _front_start_posASL = _vehicle_posASL vectorAdd (_forward vectorMultiply FRONT_OFFSET_MULTIPLIER);
private _adjusted_height = _vehicle getVariable[QGVAR(adjusted_height), 0];
_front_start_posASL = _front_start_posASL vectorAdd [0, 0, -0.2 + _adjusted_height]; //lower it a bit

if(isRemoteExecutedJIP) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: animation_out JIP", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	private _segments = _vehicle getVariable[QGVAR(segments), []];
	private _segments_count = (count _segments) - 1;
	private _previous = if(_segments isNotEqualTo []) then {
		_segments select -1;
	} else {
		_vehicle;
	};

	private _segment_lenght = [SEGMENT_DISTANCE, CAP_DISTANCE] select ((typeOf _previous) isEqualTo "rhs_pontoon_end_static");
	private _segment_vector = _forward vectorMultiply _segment_lenght;
	_posASL = getPosASL _segment;
	_toPosASL = _front_start_posASL vectorAdd (_segment_vector vectorMultiply _segments_count);

	_segment setPosASL _toPosASL;
};

[_vehicle, true] call FUNC_C(setIsAnimating);

//Reverse the ending ramp to have it point in the right direction
if(_isEnd) then {   
	_segment setVectorDir _forward;
};

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

private _posASL = getPosASL _segment;
private _pos2ASL = _vehicle modelToWorldWorld DECO_OFFSET;
private _vector =_posASL vectorDiff _pos2ASL;

//Step 2 move forward
_posASL = getPosASL _segment;
private _toPosASL = +_front_start_posASL;
_toPosASL set [2, _posASL#2]; //same height

private _step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime);
	
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _toPosASL, true];
    _segment setPosASL _newPosASL;
};

//Step 3 decrease height to same height as _front_start
_posASL = getPosASL _segment;
_step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime); 
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _front_start_posASL, true];
    _segment setPosASL _newPosASL;
};

//Step 4 reach destination
private _segments = _vehicle getVariable[QGVAR(segments), []];
private _segments_count = (count _segments) - 1;
private _previous = if(_segments isNotEqualTo []) then {
	_segments select -1;
} else {
	_vehicle;
};

private _segment_lenght = [SEGMENT_DISTANCE, CAP_DISTANCE] select ((typeOf _previous) isEqualTo "rhs_pontoon_end_static");
private _segment_vector = _forward vectorMultiply _segment_lenght;
_posASL = getPosASL _segment;
_toPosASL = _front_start_posASL vectorAdd (_segment_vector vectorMultiply _segments_count);

_step = 0;
while{_step < 1} do {
	_step = _step + (RATE * diag_deltaTime);
    private _newPosASL = vectorLinearConversion[0, 1, _step, _posASL, _toPosASL, true];
    _segment setPosASL _newPosASL;
};

//driver has locality
if(local _vehicle) then {
	[_front_start_posASL vectorAdd (_segment_vector vectorMultiply (_segments_count + 1))] call FUNC_O(setHelperPos);
};

//keep it here or else sound loop will go forever until all segments are done unfolding
[_vehicle, false] call FUNC_C(setIsAnimating);

//Optional Step to open up the pontoons and enable collision
if(_isEnd) then {
	[_vehicle, true] call FUNC_C(setIsAnimating);
	_segments apply {
		_x animateSource ["fold_source", 0];
		_x setPhysicsCollisionFlag true;
		playSound3D[QPATHTOF(data\fold_source.ogg), _x, false, getPosASL _x, 1, 1, 0, 0, true];
		sleep 1;
	};

	//should be the guy with gui open
	//prepare data for replacement, all local objects will be gone and replaced by server managed objects
	if(local _vehicle) then {
		private _segmentsData = [];
		_segments apply {
			_segmentsData pushBack [
				typeOf _x,
				getPosASL _x,
				[vectorDir _x, vectorUp _x]
			];
		};
		[_vehicle, player, _segmentsData] remoteExecCall [QFUNC_S(replace), [0, 2] select isMultiplayer];
	};

	[_vehicle, false] call FUNC_C(setIsAnimating);
	sleep 5;
	[_vehicle, false] call FUNC_C(removeAll);
};
