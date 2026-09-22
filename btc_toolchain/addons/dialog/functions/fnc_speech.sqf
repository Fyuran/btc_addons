#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_dialog_fnc_speech

Description:
    Initiates interactive speech/dialog conversation loaded from a JSON configuration table.

Parameters:
    _conv_name: STRING
    _path: STRING

Returns:

Examples:
    (begin example)
        ["conv_1"] call btc_toolchain_dialog_fnc_speech;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
    ["_conv_name", "", [""]],
	["_path", "conv_table.json", [""]] //loadFile does not support absolute paths such as getMissionPath
];
if(!hasInterface) exitWith {};
disableSerialization;

if (!canSuspend) exitWith {
	[["%1: attempted to call in unscheduled envinronment, use spawn to call this function", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (_conv_name isEqualTo "") exitWith {
	[["%1: _conv_name is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (_path isEqualTo "") exitWith {
	[["%1: _path is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (!fileExists _path) exitWith {
	[["%1: _path: '%2' is empty or file not found", __FILE_NAME__, _path], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (!isNil QGVAR(box_handle) && {!scriptDone GVAR(box_handle)}) then {
	private _time = CBA_missionTime + 10;
	waitUntil {scriptDone GVAR(box_handle) || _time <= CBA_missionTime};
};

GVAR(box_handle) = [_conv_name, _path] spawn {
	params[
		["_conv_name", "", [""]],
		["_path", "", [""]]
	];

	private _raw_json = loadFile _path;
	if (_raw_json isEqualTo "") exitWith {
		[["%1: _path: '%2' is empty or file not found", __FILE_NAME__, _path], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};

	private _json = fromJSON _raw_json;
	if (isNil "_json" || {!(_json isEqualType createHashMap)}) exitWith {
		[["%1: _path: '%2' does not lead to a valid JSON type", __FILE_NAME__, _path], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};
	if (_json isEqualTo createHashMap) exitWith {
		[["%1: _json is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};

	private _conversation = _json getOrDefault [_conv_name, createHashMap];
	if (_conversation isEqualTo createHashMap) exitWith {
		[["%1: _conversation is invalid", __FILE_NAME__, _conv_name], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};

	private _speeches = _conversation getOrDefault ["speeches", createHashMap];
	if (isNil "_speeches" || {_speeches isEqualTo createHashMap}) exitWith {
		[["%1: no speeches found in conversation: %2", __FILE_NAME__, _conv_name], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};

	"btc_toolchain_dialog" cutRsc [QGVAR(RscDialogBox), "PLAIN"];
	private _dialog = uiNamespace getVariable [QGVAR(RscDialogBox), displayNull];
	if (isNull _dialog) exitWith {
		[["%1: btc_toolchain_dialog_RscDialogBox not found, something went wrong", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);  
	};
	private _text_box = _dialog displayCtrl 1000;
	//private _frame = _dialog displayCtrl 1801;
	private _picture = _dialog displayCtrl 1200;

	for "_i" from 1 to (count _speeches) do {
		private _y = _speeches getOrDefault [(format ["speech_%1", _i]), createHashMap];
		if (_y isEqualTo createHashMap) then { // failsafe for bad conv tables
			[["%1: bad conv table: %2", __FILE_NAME__, format ["speech_%1", _i]], REPORT, QCOMPONENT] call EFUNC(tools,debug);
			continue;
		};

		private _duration = (_y getOrDefault ["duration", 0]) + 2;
		private _speakerStr = _y getOrDefault ["speaker", ""];
		private _speaker = missionNamespace getVariable [_speakerStr, objNull];
		private _soundset = _y getOrDefault ["soundset", createHashMap];

		private _portrait = _y getOrDefault ["portrait", QPATHTOF(data\unknown_portrait.paa)];
		_picture ctrlSetText _portrait;

		private _rawText = _y getOrDefault ["text", "NO TEXT KEY FOUND"];
		private _text = if (isLocalized _rawText) then { localize _rawText } else { _rawText };
		_text_box ctrlSetText _text;

		private _radio_in = _conversation getOrDefault ["radio_in", []];
		if (_radio_in isEqualTo []) then {
			_radio_in = RADIO_IN_ARR;
		};
		private _radio_out = _conversation getOrDefault ["radio_out", []];
		if (_radio_out isEqualTo []) then {
			_radio_out = RADIO_OUT_ARR;
		};

		_radio_in = [selectRandom _radio_in] call EFUNC(tools,resolvePath);
		_radio_out = [selectRandom _radio_out] call EFUNC(tools,resolvePath);

		private _basic_sound = [_soundset getOrDefault ["basic", ""]] call EFUNC(tools,resolvePath);
		private _radio_sound = [_soundset getOrDefault ["radio", ""]] call EFUNC(tools,resolvePath);

		if (_speaker isNotEqualTo player) then {
			if (_radio_in isNotEqualTo []) then {
				playSoundUI [_radio_in, 2];
				sleep 0.1;
			};
			if (_radio_sound isNotEqualTo "") then {
				playSoundUI [_radio_sound, 2];
			};
		};

		if (alive _speaker) then {
			if (_basic_sound isNotEqualTo "") then {
				sleep 0.05;
				if (_speaker isEqualTo player) then {
					playSoundUI [_basic_sound, 2];
				} else {
					playSound3D [_basic_sound, _speaker, false, getPosASL _speaker, 1];
				};
			};

			private _time = CBA_missionTime + _duration;
			private _ehDraw = -1;
			if (_speaker isNotEqualTo player) then {
				GVAR(currentSpeaker) = _speaker;
				_ehDraw = addMissionEventHandler ["Draw3D", {
					private _spk = GVAR(currentSpeaker);
					if (isNil "_spk" || {!alive _spk}) exitWith {};
					private _headPos = _spk modelToWorldVisual (_spk selectionPosition "head");
					if (_headPos isEqualTo [0, 0, 0]) then { _headPos = (getPosVisual _spk) vectorAdd [0, 0, 1.7]; };
					private _distance = (player distance _spk) max 0.5;
					private _size = (3 / _distance) min 1.2 max 0.3;
					private _opacity = (2 / _distance) min 1 max 0.3;
					drawIcon3D [
						QPATHTOF(data\speaker_icon.paa),
						[1, 1, 1, _opacity],
						_headPos vectorAdd [0, 0, 0.5],
						_size,
						_size,
						0
					];
				}];
			};

			waitUntil { CBA_missionTime >= _time };

			if (_ehDraw isNotEqualTo -1) then {
				removeMissionEventHandler ["Draw3D", _ehDraw];
				GVAR(currentSpeaker) = nil;
			};
		} else {
			if (_basic_sound isNotEqualTo "") then {
				sleep 0.05;
				playSoundUI [_basic_sound, 2];
			};
			sleep _duration;
		};

		if (_speaker isNotEqualTo player && {_radio_out isNotEqualTo []}) then {
			playSoundUI [_radio_out, 2];
		};

		sleep 0.1;
	};
	"btc_toolchain_dialog" cutText ["", "PLAIN"];
};
