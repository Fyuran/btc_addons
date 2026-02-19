#include "..\script_component.hpp"
#define RADIO_IN1 "\a3\dubbing_radio_f\Sfx\in2a.ogg"
#define RADIO_IN2 "\a3\dubbing_radio_f\Sfx\in2b.ogg"
#define RADIO_IN3 "\a3\dubbing_radio_f\Sfx\in2c.ogg"
#define RADIO_IN_ARR [RADIO_IN1,RADIO_IN2,RADIO_IN3]

#define RADIO_OUT1 "\a3\dubbing_radio_f\Sfx\out2a.ogg"
#define RADIO_OUT2 "\a3\dubbing_radio_f\Sfx\out2b.ogg"
#define RADIO_OUT3 "\a3\dubbing_radio_f\Sfx\out2c.ogg"
#define RADIO_OUT_ARR [RADIO_OUT1,RADIO_OUT2,RADIO_OUT3]
/* ----------------------------------------------------------------------------
Function: btc_dialog_fnc_speech

Description:
    Initiates snowfall.

Parameters:
    _convo: string

Returns:

Examples:
    (begin example)
	[] call btc_dialog_fnc_speech;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
    ["_conv_name", "", [""]],
	["_path", getMissionPath "conv_table.json", [""]]
];
if(!hasInterface) exitWith {};
disableSerialization;

if (!canSuspend) exitWith {
	[["% 1: attempted to call in unscheduled envinronment, use spawn to call this function", __FILE_NAME__], REPORT, "dialog"] call EFUNC(tools,debug);
};
if (!isNil QGVAR(box_handle) && {!scriptDone GVAR(box_handle)}) then {
	private _time = CBA_missionTime + 10;
	waitUntil {scriptDone GVAR(box_handle) || _time <= CBA_missionTime};
};

GVAR(box_handle) = [_conv_name] spawn {
params[
	["_conv_name", "", [""]]
];
	private _speeches = ((fromJSON (loadFile "conv_table.json")) getOrDefault [_conv_name, createHashMap]) getOrDefault ["speeches", createHashMap];
	if (_speeches isEqualTo createHashMap) exitWith {
		[["no conv found by that name: %1", _conv_name], 6] call EFUNC(tools,debug);
	};
	
	"btc_dialog" cutRsc [QGVAR(RscDialogBox), "PLAIN"];
	private _dialog = uiNamespace getVariable [QGVAR(RscDialogBox), displayNull];
	if (isNull _dialog) exitWith {
	  [["% 1: btc_dialog_RscDialogBox not found, something went wrong", __FILE_NAME__], REPORT, "dialog"] call EFUNC(tools,debug);  
	};
	private _text_box = _dialog displayCtrl 1000;
	//private _frame = _dialog displayCtrl 1801;
	private _picture = _dialog displayCtrl 1200;
	
	for "_i" from 1 to (count _speeches) do {
		private _y = _speeches getOrDefault [(format["speech_%1", _i]), createHashMap];
		if (_y isEqualTo createHashMap) then { //failsafe for bad conv tables
			[["% 1: bad conv table: %2", __FILE_NAME__, format["speech_%1", _i]], REPORT, "dialog"] call EFUNC(tools,debug);
			continue;
		};
		private _duration = (_y getOrDefault ["duration", 0]) + 2;
		private _speaker = missionNamespace getVariable [_y get "speaker", objNull];
		private _soundset = _y getOrDefault ["soundset", createHashMap];
		private _portrait = if ((_y getOrDefault ["portrait", ""]) isNotEqualTo "") then {
			private _p = _y get "portrait";
			_picture ctrlSetText (getMissionPath _p);
			_p;
		} else {
			private _p = QPATHTOF(data\unknown_portrait.paa);
			_picture ctrlSetText _p;
			_p;
		};
		private _text = localize (_y getOrDefault ["text", "NO TEXT KEY FOUND"]);

		private _radio_in = if ((_speeches getOrDefault ["radio_in", []]) isNotEqualTo []) then {_speeches get "radio_in"} else {RADIO_IN_ARR};
		private _radio_out = if ((_speeches getOrDefault ["radio_in", []]) isNotEqualTo []) then {_speeches get "radio_in"} else {RADIO_OUT_ARR};
		private _basic_sound = _soundset getOrDefault ["basic", ""];
		private _radio_sound = _soundset getOrDefault ["radio", ""];
		
		_text_box ctrlSetText _text;
		   
		if (_speaker isNotEqualTo player) then {
			playSoundUI [selectRandom _radio_in, 2];
			sleep 0.1;
			playSoundUI [getMissionPath _radio_sound, 2];
		};

		if (alive _speaker) then {
			sleep 0.05;
			if (_speaker isEqualTo player) then {
				playSoundUI[getMissionPath _basic_sound, 2];
			} else {
				playSound3D[getMissionPath _basic_sound, _speaker, false, getPosASL _speaker, 1];
			};
			
			private _time = CBA_missionTime + _duration;
			waitUntil{
				private _distance = (player distance2D _speaker) max 0.1; //in case speaker==player make sure it's never below 0'
				private _size = 5 / _distance;
				private _opacity = 1 / _distance; 
				drawIcon3D[QPATHTOF(data\speaker_icon.paa), [1, 1, 1, _size], (getPosVisual _speaker) vectorAdd [0, 0, 2], _size, _size, 0];
				_time <= CBA_missionTime
			}; 
		} else {
			sleep _duration;
		};
		if (_speaker isNotEqualTo player) then {
			playSoundUI [selectRandom _radio_out, 2];
		};			
		
		sleep 0.1;   
	};
	"btc_dialog" cutText ["", "PLAIN"];  
};
