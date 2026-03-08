#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_addNext

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_addNext;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_type", "rhs_pontoon_static", [""]],
	["_multiplier", 1, [123]] //use to adjust for length       
];

if((_type isEqualTo "") || !(isClass (configFile >> "CfgVehicles" >> _type))) exitWith {
	[["%1: bad _type: %2", __FILE__, _type], REPORT, QCOMPONENT] call EFUNC(tools,debug);  
};  
if(isNull GVAR(vehicle)) exitWith {
	[["%1: GVAR(vehicle) is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(GVAR(animating)) exitWith {
	hint "animating...";
};
private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
#ifdef BTC_DEBUG_BRIDGE
[["%1: segment count: %2", __FILE__, count _segments], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _vectorDir = ([(vectorDir GVAR(vehicle))#0, (vectorDir GVAR(vehicle))#1, 0]) vectorMultiply (_multiplier * (count _segments + 1));
private _posASL = getPosASL GVAR(vehicle);
private _toPosASL = _posASL vectorAdd _vectorDir;
		
private _segment = createVehicle [_type, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_segment setVectorDirAndUp[_vectorDir, [0, 0, 1]];
_segment setPosASL _posASL;     

_segments pushBack _segment;
GVAR(vehicle) setVariable[QGVAR(segments), _segments];

[_segment, _posASL, _toPosASL] spawn FUNC(animationTransition);

//Camera
GVAR(camera) camSetTarget (ASLToAGL _toPosASL);
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) camCommit 0.1; 

#ifdef BTC_DEBUG_BRIDGE
[["%1: creating segment %2 at %3", __FILE__, _type, _toPosASL], CHAT, QCOMPONENT] call EFUNC(tools,debug);
#endif

_segment
