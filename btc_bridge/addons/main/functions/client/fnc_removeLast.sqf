#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_removeLast_client

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_removeLast_client;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_animated", false, [true]]
];

if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};

if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Attempted by !hasInterface", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(!canSuspend) exitWith {
	[["%1: executed in non suspendable environment", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};

private _segments = _vehicle getVariable[QGVAR(segments), []];
if(_segments isEqualTo []) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: attempted to delete segments when none can be found", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
#ifdef BTC_DEBUG_BRIDGE
[["%1: deleting segment n %2", __FILE_NAME__, count _segments], LOGS + CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
#endif
private _segment = _segments deleteAt (count _segments - 1);
if(isNull _segment) exitWith {
	[["%1: _segment is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};

if(isNil "_segment") then {
	[["%1: _segment is nil", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
_vehicle setVariable[QGVAR(segments), _segments];

private _previous = if(_segments isEqualTo []) then {
	_vehicle
} else {
	_segments select -1
};

if(local _vehicle) then {
	[_previous] call FUNC_O(setCameraPos);
	[_segment] call FUNC_O(setHelperPos);
};

if(isRemoteExecutedJIP) exitWith {
	deleteVehicle _segment;
};

waitUntil{!(_vehicle getVariable[QGVAR(isAnimating), false])};
if(_animated) then {
	[_vehicle, _segment] call FUNC_C(animation_in);
} else {
	deleteVehicle _segment;
};
