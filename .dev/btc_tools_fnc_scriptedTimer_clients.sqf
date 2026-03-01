#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_tools_fnc_scriptedTimer_clients

Description:
    Handles timer events

Parameters:

Returns:
    None

Examples:
    (begin example)
        [60] call btc_tools_fnc_scriptedTimer_clients;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
disableSerialization;

private _fnc_update = {
	params["_hours", "_minutes", "_seconds"];
	private _textCtrl = uiNamespace getVariable["btc_tools_timer_textCtrl", controlNull];
	if(!isNull _textCtrl) then {
		private _text = format ["TIME LEFT %1:%2:%3", _hours, _minutes, _seconds];
		//diag_log format["executing scripted panic timer with: %1 and mod %2", _timeLeft, _timeLeft % 5];
		_textCtrl ctrlSetStructuredText parseText (format["<t size='1' align='center'>%1</t>", _text]);
	};
};

private _fnc_createCtrl = {
	private _textCtrl = uiNamespace getVariable["btc_tools_timer_textCtrl", controlNull];

	//Initial display
	private _safeScreen = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
	private _bigHeight = 0.143 * safezoneH;

	private _display = findDisplay 46;
	if(!isNull _textCtrl) then {
		ctrlDelete _textCtrl;
	};
	if(isNull _textCtrl) then {
		_textCtrl = _display ctrlCreate ["RscStructuredText", 6001];
		uiNamespace setVariable["btc_tools_timer_textCtrl", _textCtrl];
		//diag_log "creating ctrl";
	};

	playSoundUI [getMissionPath "timer_gong.ogg", 1, 1, true, 0, false];
	_textCtrl ctrlSetPosition [
		0.2525 * safezoneW + safezoneX, 
		0.786 * safezoneH + safezoneY, 
		0.474375 * safezoneW, 
		_bigHeight
	];
	_textCtrl ctrlSetFade 0;
	_textCtrl ctrlSetFontHeight (_safeScreen * MAX_FONT_HEIGHT);
	_textCtrl ctrlCommit 0;

	["btc_tools_timer_hideCtrl_Event", []] call CBA_fnc_localEvent;
};

private _fnc_hideCtrl = {
	[] spawn {
		private _textCtrl = uiNamespace getVariable["btc_tools_timer_textCtrl", controlNull];
		if(isNull _textCtrl) exitWith {
			//diag_log "_textCtrl is null";
		};
		
		private _safeScreen = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
		private _bigHeight = 0.143 * safezoneH;
		private _smallHeight = 0.033 * safezoneH;

		//Decrease size
		sleep 1;
		_textCtrl ctrlSetPosition [
			0.886719 * safezoneW + safezoneX,
			0.907 * safezoneH + safezoneY,
			0.0979687 * safezoneW,
			_smallHeight
		];
		_textCtrl ctrlCommit 3;

		waitUntil {
			private _ctrlHeight = (ctrlPosition _textCtrl) select 3;
			private _n = linearConversion [_smallHeight, _bigHeight, _ctrlHeight, 1, MAX_FONT_HEIGHT, true];
			_textCtrl ctrlSetFontHeight (_safeScreen * _n);

			_ctrlHeight <= _smallHeight
		};

		//Fadeout
		sleep 2;
		_textCtrl ctrlSetFade 1;
		_textCtrl ctrlCommit 2;
		sleep 2;
		ctrlDelete _textCtrl;
		//diag_log "hiding ctrl";
	};
};

private _fnc_panic = {
	[] spawn {
		private _display = findDisplay 46;
		private _textCtrl = uiNamespace getVariable["btc_tools_timer_textCtrl", controlNull];
		if(!isNull _textCtrl) then {
			ctrlDelete _textCtrl;
		};
		_textCtrl = _display ctrlCreate ["RscStructuredText", 6001];
		uiNamespace setVariable["btc_tools_timer_textCtrl", _textCtrl];

		private _safeScreen = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
		private _bigHeight = 0.143 * safezoneH;
		_textCtrl ctrlSetPosition [
			0.2525 * safezoneW + safezoneX, 
			0.786 * safezoneH + safezoneY, 
			0.474375 * safezoneW, 
			_bigHeight
		];
		_textCtrl ctrlCommit 0;
		_textCtrl ctrlSetTextColor [1, 0, 0, 1];
		
		sleep 0.2;
		private _sound = playSoundUI [getMissionPath "timer_countdown_critical.ogg", 1, 1, true, 0, true];

		//Sine Wave for text
		private _mid = (4 + 2) / 2;
		private _amp = (4 - 2) / 2;
		waitUntil {
			private _sin_textHeight = _mid + _amp * sin ( (360 / 2) * CBA_missionTime );
			_textCtrl ctrlSetFontHeight (_safeScreen * _sin_textHeight);
			not(missionNamespace getVariable["btc_tools_timer_endofline", false])
		};

		//End of line
		stopSound _sound;
		sleep 0.01;
		playSoundUI [getMissionPath "endofline.ogg", 1, 1, true, 0, false];
		_textCtrl ctrlSetStructuredText parseText (format["<t size='1' align='center'>%1</t>", "OUT OF TIME"]);
		sleep 2;
		_textCtrl ctrlSetFade 1;
		_textCtrl ctrlCommit 2;
		sleep 2;
		ctrlDelete _textCtrl;
	};
};

btc_tools_timer_createOrShow_Event = ["btc_tools_timer_createOrShow_Event", _fnc_createCtrl] call CBA_fnc_addEventHandler;
btc_tools_timer_update_Event = ["btc_tools_timer_update_Event", _fnc_update] call CBA_fnc_addEventHandler;
btc_tools_timer_hideCtrl_Event = ["btc_tools_timer_hideCtrl_Event", _fnc_hideCtrl] call CBA_fnc_addEventHandler;
btc_tools_timer_panic_Event = ["btc_tools_timer_panic_Event", _fnc_panic] call CBA_fnc_addEventHandler;
