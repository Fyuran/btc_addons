#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_addEH_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_addEH_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]]
];
if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
/*
Event Handler parameters are accessible via _this
The Event Handler type is available as _thisEvent
The Event Handler index is available as _thisEventHandler
*/

private _fnc_veh = {
	params["_vehicle"];
	if(!local _vehicle) exitWith {
		#ifdef BTC_DEBUG_BRIDGE
		[["%1: %2 triggered %3 but object is not local", __FILE_NAME__, _vehicle, _thisEvent], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
		#endif
		[_vehicle] call FUNC_O(removeEH);
	};

	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 triggered EH %3", __FILE_NAME__, _vehicle, _thisEvent], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif

	private _display = uiNamespace getVariable[QGVAR(display), displayNull];
	_display closeDisplay 1;
	
	[_vehicle] call FUNC_O(eraseJIP);
	[_vehicle] call FUNC_O(removeEH);

	[_vehicle, false] remoteExec [QFUNC_C(removeAll), [0, -2] select isDedicated];

};

private _fnc_player = {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 triggered EH %3", __FILE_NAME__, player, _thisEvent], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif

	private _vehicle = objectParent player;
	if(isNull _vehicle) exitWith {
		[["%1: _vehicle is null on %2", __FILE_NAME__, _thisEvent], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
	};
	if(!local _vehicle) exitWith {
		#ifdef BTC_DEBUG_BRIDGE
		[["%1: %2 triggered %3 but object is not local", __FILE_NAME__, player, _thisEvent], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
		#endif
		[_vehicle] call FUNC_O(removeEH);
	};

	private _display = uiNamespace getVariable[QGVAR(display), displayNull];
	_display closeDisplay 1;

	[_vehicle] call FUNC_O(eraseJIP);
	[_vehicle] call FUNC_O(removeEH);

	[_vehicle, false] remoteExec [QFUNC_C(removeAll), [0, -2] select isDedicated];
};

private _v_killedEH = _vehicle addEventHandler ["Killed", _fnc_veh];
private _v_deletedEH = _vehicle addEventHandler ["Deleted", _fnc_veh];

//Player EH
private _dammagedEH = player addEventHandler ["Dammaged", _fnc_player];
private _killedEH = player addEventHandler ["Killed", _fnc_player];

GVAR(v_EHs) = createHashMapFromArray[
	["Killed", _v_killedEH],
	["Deleted", _v_deletedEH]
];

GVAR(p_EHs) = createHashMapFromArray[
	["Dammaged", _dammagedEH],
	["Killed", _killedEH]
];
