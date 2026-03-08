#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_removeLast

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_removeLast;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
if(isNull GVAR(vehicle)) exitWith {
	[["%1: GVAR(vehicle) is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(GVAR(animating)) exitWith {
	hint "animating...";
};
private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
if(_segments isEqualTo []) exitWith {};
	
private _segment = _segments deleteAt (((count _segments) - 1) max 0);
GVAR(vehicle) setVariable[QGVAR(segments), _segments];

//Animation
_segment spawn {
	_handle = [_this, getPosASL _this, getPosASL GVAR(vehicle)] spawn FUNC(animationTransition);
	waitUntil{scriptDone _handle};
	deleteVehicle _this;
};

//Return last or nothing
private _previous = if(_segments isNotEqualTo []) then {
	_segments select -1;
} else {
	GVAR(vehicle);
};

//Camera
GVAR(camera) camSetTarget (getPos _previous);
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) camCommit 0.1;

_previous 
