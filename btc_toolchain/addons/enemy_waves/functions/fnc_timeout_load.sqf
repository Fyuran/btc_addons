#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_timeout_load

Description:
    Sets the timeout value into the edit box control.

Parameters:
    _edit: CONTROL
    _value: NUMBER/STRING

Returns:

Examples:
    (begin example)
        [_timeoutEditCtrl, 60] call btc_toolchain_enemy_waves_fnc_timeout_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrl", controlNull, [controlNull, []], [1, 2]],
    ["_value", 60, [123, ""]]
];
private _ctrlGroup = if (_ctrl isEqualType []) then {_ctrl select 0} else {_ctrl};
private _edit = if (ctrlIDC _ctrlGroup isEqualTo TIMEOUT_EDIT) then {
    _ctrlGroup
} else {
    _ctrlGroup controlsGroupCtrl TIMEOUT_EDIT
};
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing timeout load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if(_value isEqualType 123) then {
	_value = str _value;
};
_edit ctrlSetText _value;
