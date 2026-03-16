#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_addAction_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_addAction_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_segment", objNull, [objNull]]
];
#ifdef BTC_DEBUG_BRIDGE
[["%1: adding action to segment %2", __FILE_NAME__, getPosASL _segment], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

_segment addAction [
	"<t color='#E63946'>Undo Bridge</t>", 
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		private _segments = +(_target getVariable[QGVAR(segments), []]);
		reverse _segments;
		_segments apply {
			_x animateSource ["fold_source", 1];
			playSound3D[QPATHTOF(data\fold_source.ogg), _x];
			sleep 4;
			deleteVehicle _x;
		};
	}, 
	nil, 
	1.5, 
	false, 
	true, 
	"", 
	"true", 
	10, 
	false, 
	"", 
	""
];
