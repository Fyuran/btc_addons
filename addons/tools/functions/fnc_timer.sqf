#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_tools_fnc_timer

Description:
    Shows a timer that can be stopped by either timeout or a predicate

Parameters:
    _duration - How long will the timer last [Number]
    _clock - either 24 or 12 hour format. [Number]
	_predicate - Evaluted every iteration, a true will stop the timer. [Code]
    _guiPosSize - Position of the gui asset [Array]

Returns:

Examples:
    (begin example)
	[60] call btc_tools_fnc_timer;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
	["_duration", 0, [123]],
	["_clock", 24, [123]],
	["_predicate", {false}, [{}]],
	["_guiPosSize", [0.275,0.96,0.425,0.06], [[]], 4]
];
disableSerialization;
if (!isNil "btc_tools_ui_timer_handle") then {
	terminate btc_tools_ui_timer_handle;
	ctrlDelete((findDisplay 46) displayCtrl 6001); 
};
   
btc_tools_ui_timer_handle = [_duration, _clock, _predicate, _guiPosSize] spawn {
	params[
		"_duration",
		"_clock",
		"_predicate",
		"_guiPosSize"
	];
	if (_clock != 24 && _clock != 12) exitWith {
		[["%1: invalid clock time: %2", __FILE_NAME__, _clock], REPORT, QCOMPONENT] call FUNC(debug);
	};
	private _display = findDisplay 46;
	private _textCtrl = _display ctrlCreate ["RscStructuredText", 6001];
	_textCtrl ctrlSetPosition _guiPosSize;
	_textCtrl ctrlCommit 0;
	
	private _time = CBA_missionTime + _duration;
	while {(CBA_missionTime < _time)} do { 
		private _timeLeft = floor(_time - CBA_missionTime);
		if (call _predicate) then { //evaluated every iteration 
			break;
		};
		private _hours = "00";
		if (_timeLeft >= 3600) then {
			private _h = (floor(_timeLeft / 3600)) mod _clock;
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
		
		private _text = format ["%1:%2:%3", _hours, _minutes, _seconds];	 
	
		_textCtrl ctrlSetStructuredText parseText (format["<t size='1' align='center'>%1</t>", _text]);
		sleep 1;
	};
	_textCtrl ctrlSetFade 1;
	_textCtrl ctrlCommit 1;
	sleep 1;
	ctrlDelete _textCtrl;	 
};
