#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_removeAll

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_removeAll;
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
	[["%1: attempted to removeAll segments when none can be found", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
#ifdef BTC_DEBUG_BRIDGE
[["%1: deleting all %2 segments", __FILE_NAME__, count _segments], LOGS + CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

for "_i" from 0 to (count _segments - 1) do {
	private _segment = _segments deleteAt (count _segments - 1);
	if(!local _segment) then {
		#ifdef BTC_DEBUG_BRIDGE
		[["%1: attempted to call removeAll animated on non local segments", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
		#endif
	} else {
		waitUntil{!(_vehicle getVariable[QGVAR(isAnimating), false])};
		if(_animated) then {
			[_vehicle, _segment] call FUNC_C(animation_in);
		} else {
			deleteVehicle _segment;
		};
	};
};

if(local _vehicle) then {
	[_vehicle] call FUNC_O(setCameraPos);
};
_vehicle setVariable[QGVAR(segments), []];
_vehicle setVariable[QGVAR(adjusted_height), 0];
