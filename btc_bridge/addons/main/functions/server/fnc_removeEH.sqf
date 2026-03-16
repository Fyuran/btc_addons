#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_removeEH_server

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_removeEH_server;
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

GVAR(v_server_EHs) apply {
	[_x, _y] params[
		["_eh", "", [""]],
		["_handle", -1, [123]]
	];

	_vehicle removeEventHandler [_eh, _handle];
};

GVAR(p_server_EHs) apply {
	[_x, _y] params[
		["_eh", "", [""]],
		["_handle", -1, [123]]
	];

	_player removeEventHandler [_eh, _handle];
};

GVAR(v_server_EHs) = createHashMap;
GVAR(p_server_EHs) = createHashMap;
_vehicle setVariable[QGVAR(player), objNull];
_vehicle setVariable [QGVAR(server_segments), []];
_player setVariable[QGVAR(vehicle), objNull];
