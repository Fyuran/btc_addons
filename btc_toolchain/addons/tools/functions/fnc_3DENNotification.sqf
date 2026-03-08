#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_3DENNotification

Description:
    Acts as a wrapper for Eden editor notifications, forwarding them to either standard error display or eden's notification popup

Parameters:

Returns:

Examples:
    (begin example)
		[] call btc_toolchain_tools_fnc_3DENNotification;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_class", "", [123, ""]],
	["_type", 0, [123, false]],
	["_duration", -1, [123]],
	["_animate", true, [true]],
	["_volume", 1, [123]]
];

if(is3DEN) exitWith {
	[_class, _type, _duration, _animate, _volume] call BIS_fnc_3DENNotification;
};

private _sounds = ["3DEN_notificationDefault","3DEN_notificationWarning","3DEN_notificationWarning"];
playSoundUI [_sounds select _type, _volume];
[_class] call BIS_fnc_error;
