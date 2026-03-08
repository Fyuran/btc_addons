/* ----------------------------------------------------------------------------
Function: CBA_fnc_debug2

Description:
    General Purpose Debug Message Writer

    Handles very long messages without losing text.

Parameters:
    _message - Message to write <STRING, ARRAY>
    _title   - Message title (optional, default: "cba_diagnostic") <STRING>
    _type    - Type of message <ARRAY>
        0: _useChat - Write to chat (optional, default: true) <BOOLEAN>
        1: _useLog  - Log to arma.rpt (optional, default: true) <BOOLEAN>
        2: _global  - true: execute global (optional, default: false) <BOOLEAN>

Returns:
    nil

Examples:
    (begin example)
        // Write the debug message in chat-log of every client
        ["New Player Joined the Server!", "cba_network", [true, false, true]] call CBA_fnc_debug2;
    (end)

Edit: 
    Removed the timestamp

Author:
    Sickboy, commy2, Fyuran
---------------------------------------------------------------------------- */

// function to split lines into multiple lines with a maxium length
#define MAX_LINE_LENGTH 120

private _fnc_splitLines = {
	private _return = [];

	{
		private _string = _x;

		while {count _string > 0} do {
			_return pushBack (_string select [0, MAX_LINE_LENGTH]);
			_string = _string select [MAX_LINE_LENGTH];
		};
	} forEach _this;

	_return
};


if (isNil "cba_diagnostic_logic") then {
	cba_diagnostic_logic = "Logic" createVehicleLocal [0, 0, 0];
};


params [["_message", "", ["", []]], ["_title", 'cba_diagnostic', [""]], ["_type", [], [[]]]];

_type params [
	["_useChat", true, [false]],
	["_useLog", true, [false]],
	["_global", false, [false]]
];


if (_global) then {
	["cba_diagnostic_debug", [_message, _title, [_useChat, _useLog, false]]] call CBA_fnc_remoteEvent;
};


if (_message isEqualType "") then {
	_message = [_message, "\n"] call CBA_fnc_split;
};

// format the first line to include title
_message set [0, format [
    "%1 %2",
    _title,
    _message select 0
]];

_message = _message call _fnc_splitLines;


if (_useChat) then {

	if (time < 1) then {
		_message spawn {
			uiSleep 1;

			{
				cba_diagnostic_logic globalChat _x;
			} forEach _this;
		};
	} else {
		{
			cba_diagnostic_logic globalChat _x;
		} forEach _message;
	};
};


if (_useLog) then {
	{
		diag_log text _x;
	} forEach _message;
};
