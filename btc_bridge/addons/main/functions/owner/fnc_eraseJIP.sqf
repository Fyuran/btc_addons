#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_eraseJIP_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_eraseJIP_owner;
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
#ifdef BTC_DEBUG_BRIDGE
[["%1: erasing JIPs", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

private _segments = _vehicle getVariable[QGVAR(segments), []];
private _segments_count = count _segments;
private _uid = _vehicle getVariable[QGVAR(JIPUID), ""];

for "_i" from 0 to _segments_count do {
	private _jipID = format["btc_bridge_%1_segment_%2", _uid, _i];
	remoteExec ["", _jipID];
};

//erase JIP ids for both negative and positive increments
for "_i" from 0 to BRIDGE_HEIGHT_LIMIT step BRIDGE_HEIGHT_STEP do {
	private _jipID = format["btc_bridge_%1_%2_height", _uid, _i];
	remoteExec ["", _jipID];

	private _jipID = format["btc_bridge_%1_%2_height", _uid, -_i];
	remoteExec ["", _jipID];
};
