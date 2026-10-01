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
    ["_ctrl", controlNull, [controlNull, []], [1, 2]]
];
private _ctrlGroup = if (_ctrl isEqualType []) then {_ctrl select 0} else {_ctrl};
private _edit = if (ctrlIDC _ctrlGroup isEqualTo TIMEOUT_EDIT) then {
    _ctrlGroup
} else {
    _ctrlGroup controlsGroupCtrl TIMEOUT_EDIT
};
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing timeout save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

parseNumber(ctrlText _edit);
