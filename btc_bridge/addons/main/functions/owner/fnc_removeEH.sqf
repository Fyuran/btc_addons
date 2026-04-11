#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_removeEH_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_removeEH_owner;
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
[["%1: removing EHs: %2, %3", __FILE_NAME__, GVAR(v_EHs), GVAR(p_EHs)], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

GVAR(v_EHs) apply {
	[_x, _y] params[
		["_eh", "", [""]],
		["_handle", -1, [123]]
	];

	_vehicle removeEventHandler [_eh, _handle];
};

GVAR(p_EHs) apply {
	[_x, _y] params[
		["_eh", "", [""]],
		["_handle", -1, [123]]
	];

	player removeEventHandler [_eh, _handle];
};

GVAR(v_EHs) = createHashMap;
GVAR(p_EHs) = createHashMap;
