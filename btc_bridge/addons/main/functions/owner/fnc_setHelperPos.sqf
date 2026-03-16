#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_setHelperPos_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_setHelperPos_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_posASL", [0, 0, 0], [[], objNull]]
];
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(isNull (missionNamespace getVariable[QGVAR(helper), objNull])) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: helper is null", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(_posASL isEqualType objNull) then {
	if(!isNull _posASL) then {
		_posASL = getPosASL _posASL;
	} else {
		_posASL = [0, 0, 0];
	};
};
if(_posASL isEqualTo [0,0,0]) exitWith {
	[["%1: _posASL is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};

#ifdef BTC_DEBUG_BRIDGE
[["%1: setting helper pos to %2", __FILE_NAME__, _posASL], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif
GVAR(helper) setPosASL _posASL;
