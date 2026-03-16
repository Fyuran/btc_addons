#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_addEH_server

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_addEH_server;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_player", objNull, [objNull]]
];
if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(isNull _player) exitWith {
	[["%1: _player is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: attempted to execute server only fnc", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
/*
Event Handler parameters are accessible via _this
The Event Handler type is available as _thisEvent
The Event Handler index is available as _thisEventHandler
*/
_vehicle setVariable[QGVAR(player), _player];
_player setVariable[QGVAR(vehicle), _vehicle];

private _fnc_veh = {
	params["_vehicle"];
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 triggered EH %3", __FILE_NAME__, _vehicle, _thisEvent], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif

	[[_vehicle], {
		params["_vehicle"];
		private _display = uiNamespace getVariable[QGVAR(display), displayNull];
		_display closeDisplay 1;
		
		[_vehicle] call FUNC_O(eraseJIP);
	}] remoteExecCall ["call", _vehicle];
	[_vehicle, false] remoteExec [QFUNC_C(removeAll), [0, -2] select isDedicated];

	if(_thisEvent isEqualTo "Killed" || (_thisEvent isEqualTo "Deleted")) then {
		private _deco = _vehicle getVariable[QGVAR(deco), objNull];
		deleteVehicle _deco;
	};
	private _player = _vehicle getVariable[QGVAR(player), objNull];
	[_vehicle, _player] call FUNC_S(removeEH);
};

private _fnc_player = {
	params["_player"];
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 triggered EH %3", __FILE_NAME__, _player, _thisEvent], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif

	private _vehicle = _player getVariable[QGVAR(vehicle), objNull];
	[[_vehicle], {
		params["_vehicle"];
		private _display = uiNamespace getVariable[QGVAR(display), displayNull];
		_display closeDisplay 1;

		[_vehicle] call FUNC_O(eraseJIP);
	}] remoteExecCall ["call", _vehicle];
	[_vehicle, false] remoteExec [QFUNC_C(removeAll), [0, -2] select isDedicated];

	[_vehicle, _player] call FUNC_S(removeEH);
};

private _v_dammagedEH = _vehicle addEventHandler ["Dammaged", _fnc_veh];
private _v_killedEH = _vehicle addEventHandler ["Killed", _fnc_veh];
private _v_deletedEH = _vehicle addEventHandler ["Deleted", _fnc_veh];

//Player EH
private _dammagedEH = _player addEventHandler ["Dammaged", _fnc_player];
private _killedEH = _player addEventHandler ["Killed", _fnc_player];

GVAR(v_server_EHs) = createHashMapFromArray[
	["Dammaged", _v_dammagedEH],
	["Killed", _v_killedEH],
	["Deleted", _v_deletedEH]
];

GVAR(p_server_EHs) = createHashMapFromArray[
	["Dammaged", _dammagedEH],
	["Killed", _killedEH]
];
