#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_cleanUp_server

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_cleanUp_server;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_player", objNull, [objNull]],
	["_segmentsData", [], [[]]]
];

if(isNull _vehicle) exitWith {
	[["%1: vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(_segmentsData isEqualTo []) exitWith {
	[["%1: _segmentsData is empty", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: attempted to execute server only fnc", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};


private _segments = _vehicle getVariable [QGVAR(server_segments), []];
if(_segments isNotEqualTo []) then {
	_segments apply {
		deleteVehicle _x;
	};
	_segments = [];
};
_segmentsData apply {
	_x params[
		["_class", "", [""]], 
		["_posASL", [0,0,0], [[]], 3],
		["_vectorDirAndUp", [[0,0,0], [0,0,1]], [[]], 2]
	];
	private _segment = createVehicle[_class, _posASL, [], 0, "CAN_COLLIDE"];
	_segment setVectorDirAndUp _vectorDirAndUp;
	_segment setPosASL _posASL;
	_segments pushBack _segment;
};

#ifdef BTC_DEBUG_BRIDGE
[["%1: replacing local segments with server segments %2", __FILE_NAME__, _segmentsData], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif


private _first_segment = _segments select 0;
_first_segment setVariable[QGVAR(segments), _segments, owner _vehicle];
[_first_segment] remoteExecCall [QFUNC_O(addAction), _player];

_vehicle setVariable [QGVAR(server_segments), _segments];
[_vehicle, _player] call FUNC_S(removeEH);
