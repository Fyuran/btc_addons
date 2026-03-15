#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_addNext_client

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_addNext_client;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_isEnd", false, [true]]
];
if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(!canSuspend) exitWith {
	[["%1: executed in non suspendable environment", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};

private _segments = _vehicle getVariable[QGVAR(segments), []];

private _class = "rhs_pontoon_static";
if(_segments isEqualTo [] || _isEnd) then {            
	_class = "rhs_pontoon_end_static";
};
private _segment = createVehicleLocal [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_segment setPhysicsCollisionFlag false;
_segment animateSource ["fold_source", 1, true];

#ifdef BTC_DEBUG_BRIDGE
[["%1: creating segment %2, total %3", __FILE_NAME__, typeOf _segment, count _segments], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
#endif
waitUntil{!(_vehicle getVariable[QGVAR(isAnimating), false])};

_segment setPosASL (_vehicle modelToWorldWorld DECO_OFFSET);
private _vectorDir = vectorDir _vehicle;
_vectorDir set[2, 0];
_segment setVectorDirAndUp[_vectorDir, [0, 0, 1]];

_segments pushBack _segment;

_vehicle setVariable[QGVAR(segments), _segments];

[_vehicle, _segment, _isEnd] call FUNC_C(animation_out);

if(!_isEnd && {local _vehicle}) then {
	[_segment] call FUNC_O(setCameraPos);
};

_segment
