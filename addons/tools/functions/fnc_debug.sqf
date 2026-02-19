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
        [["% 1: Hello World", __FILE_NAME__], CHAT, "debug"] call EFUNC(tools,debug);
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_message", ["BTC Message debug"], [[""]]],
    ["_mode", 0, [123]],
    ["_title", "DEBUG", [""]]
];
if (_mode <= 0 || _mode > 15) exitWith {
    #ifdef BTC_DEBUG_DEBUG
    [["%1: invalid _mode: %2 passed to btc_debug_fnc_message", __FILE_NAME__, _mode], 6, "debug"] call FUNC(debug);  
    #endif
};

private _useChat = [_mode, CHAT] call BIS_fnc_bitflagsCheck;
private _useLogs = [_mode, LOGS] call BIS_fnc_bitflagsCheck;
private _isError = [_mode, REPORT] call BIS_fnc_bitflagsCheck;
private _global = [_mode, GLOBAL] call BIS_fnc_bitflagsCheck;

if(_title isNotEqualTo "DEBUG") then {
    _title = format["[BTC] (%1)", toUpper _title];
};

if(!_isError) then {
    [format _message, _title, [_useChat, _useLogs, _global]] call CBA_fnc_debug2;
} else { //it's an REPORT message
    ["%1", format _message] remoteExecCall ["BIS_fnc_error", 0];
    _title = format["%1 REPORT", _title];
    [format _message, _title, [_useChat, _useLogs, _global]] call CBA_fnc_debug2;
};

