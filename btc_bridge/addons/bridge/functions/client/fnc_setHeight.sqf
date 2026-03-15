#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_setHeight_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_setHeight_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_isUp", true, [false]]
];
if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Attempted by !hasInterface", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
if(!canSuspend) exitWith {
	[["%1: executed in non suspendable environment", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};

waitUntil{!(_vehicle getVariable[QGVAR(isAnimating), false])};

private _segments = _vehicle getVariable[QGVAR(segments), []];
private _increment = [-BRIDGE_HEIGHT_STEP, BRIDGE_HEIGHT_STEP] select _isUp;

private _adjusted_height = _vehicle getVariable[QGVAR(adjusted_height), 0];

if(isRemoteExecutedJIP) exitWith {
	_segments apply {
		private _posASL = getPosASL _x;
		private _toPosASL = _posASL vectorAdd [0, 0, _increment];

		_x setPosASL _toPosASL;
	};
};

_adjusted_height = _adjusted_height + _increment;
//Using the GUI
if(local _vehicle) then {
	private _display = uiNamespace getVariable[QGVAR(display), displayNull];
	if(isNull _display) exitWith {
		[["%1: vehicle is local, but no display found", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
	};
	private _ctrlGrp = _display displayCtrl CTRL_GRP;
	private _heightCtrl = _ctrlGrp controlsGroupCtrl 1006;

	_heightCtrl ctrlSetStructuredText parseText format["<t color='#b40379' font='PuristaBold'>Bridge Height: %1</t>", _adjusted_height];
};

if((_adjusted_height < -BRIDGE_HEIGHT_LIMIT) || (_adjusted_height > BRIDGE_HEIGHT_LIMIT)) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Height threshold reached, exiting", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
_vehicle setVariable[QGVAR(adjusted_height), _adjusted_height];

#ifdef BTC_DEBUG_BRIDGE
[["%1: adjusting bridge height by %2", __FILE_NAME__, _adjusted_height], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

[_vehicle, true] call FUNC_C(setIsAnimating);
_segments apply {
	private _step = 0;
	private _posASL = getPosASL _x;
	playSound3D[QPATHTOF(data\fold_source.ogg), _x, false, getPosASL _x, 1, 1, 0, 0, true];
	while{_step < 1} do {
		private _toPosASL = vectorLinearConversion [0, 1, _step, _posASL, _posASL vectorAdd [0, 0, _increment], true];

		_x setPosASL _toPosASL;
		_step = _step + (RATE * diag_deltaTime);
	};
	sleep 0.5;
};
[_vehicle, false] call FUNC_C(setIsAnimating);
