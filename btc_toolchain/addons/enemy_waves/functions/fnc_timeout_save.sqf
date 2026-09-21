#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_timeout_save

Description:
    Parses and returns the numeric timeout value from the timeout edit box control.

Parameters:
    _edit: CONTROL

Returns:
    NUMBER

Examples:
    (begin example)
        private _timeoutSec = [_timeoutEditCtrl] call btc_toolchain_enemy_waves_fnc_timeout_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_edit", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing timeout save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

parseNumber(ctrlText _edit);
