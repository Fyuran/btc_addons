#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_setCameraPos_owner

Description:
    Moves and refocuses the bridge operator camera to target a specified position or bridge segment.

Parameters:
    _pos: ARRAY/OBJECT

Returns:

Examples:
    (begin example)
        [_segment] call btc_bridge_fnc_setCameraPos_owner;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_pos", [0, 0, 0], [[], objNull]]
];
if(isNull (missionNamespace getVariable[QGVAR(camera), objNull])) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: camera is null", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

if(_pos isEqualType objNull) then {
	if(!isNull _pos) then {
		_pos = getPos _pos;
	} else {
		_pos = [0,0,0];
	};
};
if(_pos isEqualTo [0,0,0]) exitWith {
	[["%1: _pos is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};

#ifdef BTC_DEBUG_BRIDGE
[["%1: setting camera pos to %2", __FILE_NAME__, _pos], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif
GVAR(camera) camSetTarget _pos;
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) camCommit 0.1;
