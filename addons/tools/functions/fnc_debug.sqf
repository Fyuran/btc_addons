#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_debug_fnc_message

Description:
    Reports diagnostics information to rpt and user screen

Parameters:
    _message - [String]
    _mode - [Array]
    _file - [String]

Returns:

Examples:
    (begin example)
        [["%1: Hello World", __FILE_NAME__], CHAT, QCOMPONENT] call EFUNC(tools,debug);
        [["%1: Hello World", __FILE_NAME__], CHAT, QCOMPONENT] call FUNC(debug);
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_message", ["BTC Message debug"], [[""]]],
    ["_mode", 0, [123]],
    ["_title", "DEBUG", [""]]
];
if (_mode <= 0 || _mode > GLOBAL) exitWith {
    #ifdef BTC_DEBUG_DEBUG
    [["%1: invalid _mode: %2 passed to btc_debug_fnc_message", __FILE_NAME__, _mode], REPORT, QCOMPONENT] call FUNC(debug);  
    #endif
};

private _useChat = [_mode, CHAT] call BIS_fnc_bitflagsCheck;
private _useLogs = [_mode, LOGS] call BIS_fnc_bitflagsCheck;
private _isError = [_mode, REPORT] call BIS_fnc_bitflagsCheck;
private _global = [_mode, GLOBAL] call BIS_fnc_bitflagsCheck;

if(_title isNotEqualTo "DEBUG") then {
    _title = format["[BTC] (%1)", toUpper _title];
};

_message = format _message;
if(!_isError) then {
    [_message, _title, [_useChat, _useLogs, _global]] CBAFUNC(debug2);
} else { //it's an REPORT message
	if(is3DEN) then {
		[_message, 1] call BIS_fnc_3DENNotification;
	};
    _title = format["%1 ERROR", _title];
    [_message, _title, [_useChat, _useLogs, _global]] CBAFUNC(debug2);
};

