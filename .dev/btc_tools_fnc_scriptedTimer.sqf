#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_tools_fnc_scriptedTimer

Description:
    Handles a timer, executing passed scripts each second

Parameters:
    _duration - time in seconds. [Number]
    _interval - When should timer trigger events. [Number]

Returns:
    None

Examples:
    (begin example)
        [120, 10] call btc_tools_fnc_scriptedTimer;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_duration", 0, [123]],
	["_interval", 60, [123]]
];

if (!isNil "btc_tools_scripted_timer_handle") then {
	missionNamespace setVariable ["btc_tools_timer_endofline", false, true];
	[btc_tools_scripted_timer_handle] call CBA_fnc_removePerFrameHandler;
};

btc_tools_scripted_timer_shutdown = {
	missionNamespace setVariable ["btc_tools_timer_endofline", false, true];
	[btc_tools_scripted_timer_handle] call CBA_fnc_removePerFrameHandler;
};

_duration = _duration + 1;
btc_tools_timer_endofline = false;
btc_tools_scripted_timer_handle = [{
	(_this#0) params[
		"_duration",
		"_interval",
		"_time"
	];
	if (isGamePaused) exitWith {};
	if((CBA_missionTime) >= _duration) exitWith {
		missionNamespace setVariable ["btc_tools_timer_endofline", false, true];
		[(_this#1)] call CBA_fnc_removePerFrameHandler;
	};
	private _timeLeft = (floor(_time - CBA_missionTime)) max 0;

	private _hours = "00";
	if (_timeLeft >= 3600) then {
		private _h = (floor(_timeLeft / 3600)) mod 24;
		if (_h < 10) then { //add padding
			_h = format["0%1", _h];
		};
		_hours = _h;
	};
	private _minutes = "00";
	if (_timeLeft >= 60) then {
		private _m = (floor(_timeLeft / 60)) mod 60;
		if (_m < 10) then { //add padding
			_m = format["0%1", _m];
		};
		_minutes = _m;
	};
	private _seconds = "00";
	private _s = _timeLeft mod 60;
	if (_s < 10) then { //add padding
		_seconds = format ["0%1", _s];		
	} else {
		_seconds = format ["%1", _s]; 
	};
	
	diag_log format["_timeLeft: %1", _timeLeft];
	if(_timeLeft >= 60) then {
		if((_timeLeft % _interval) isEqualTo 0) then {
			["btc_tools_timer_createOrShow_Event", []] call CBA_fnc_globalEvent;
		};
	};
	if(_timeLeft <= 30) then {
		if(!btc_tools_timer_endofline) then {
			missionNamespace setVariable ["btc_tools_timer_endofline", true, true];
			["btc_tools_timer_panic_Event", []] call CBA_fnc_globalEvent;
		};
	};

	["btc_tools_timer_update_Event", [_hours, _minutes, _seconds]] call CBA_fnc_globalEvent;

}, 1, [_duration, _interval, CBA_missionTime + _duration]] call CBA_fnc_addPerFrameHandler;
