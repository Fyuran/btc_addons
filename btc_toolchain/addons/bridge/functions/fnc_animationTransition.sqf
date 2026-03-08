#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_animationTransition

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_animationTransition;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_segment", objNull, [objNull]],
	["_posASL", [0, 0, 0], [[]], 3],
	["_toPosASL", [0, 0, 0], [[]], 3]
];

if(isNull _segment) exitWith {
	[["%1: _segment is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!canSuspend) exitWith {
	[["%1: executed in non suspendable environment", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug); 
};
//queue up animation spawns
waitUntil{!GVAR(animating)};
private _vectorDir = vectorDir _segment;	
GVAR(animating) = true;

//audio
_segment spawn {
	playSound3D[QPATHTOF(data\hydraulic_start.ogg), _this];
	sleep 0.750;
	while{GVAR(animation_time) < 0.964} do {
		playSound3D[QPATHTOF(data\hydraulic_loop.ogg), _this];
		sleep 0.991;
	};
	playSound3D[QPATHTOF(data\hydraulic_end.ogg), _this];
};

#ifdef BTC_DEBUG_BRIDGE
[["%1: Animating %2 from %3 to %4", __FILE__, _segment, _posASL, _toPosASL], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug); 
#endif
_segment setPhysicsCollisionFlag false;	
GVAR(animation_time) = 0;
while{GVAR(animation_time) < 1} do {
	_segment setVelocityTransformation [
		_posASL, _toPosASL, 
		[0, 0, 0], [0, 0, 0], 
		_vectorDir, _vectorDir, 
		[0, 0, 1], [0, 0, 1], 
		GVAR(animation_time)
	];
	GVAR(animation_time) = GVAR(animation_time) + (0.001 * diag_deltaTime);
};
	
GVAR(animating) = false;
_segment setPhysicsCollisionFlag true;
