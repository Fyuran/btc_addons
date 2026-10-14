#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_timeout_attributeLoad

Description:
    Sets the timeout value into the edit box control.

Parameters:
    _edit: CONTROL - Timeout edit box control
    _value: NUMBER or STRING - Timeout value in seconds (optional, default: 60)

Returns:

Examples:
    (begin example)
        [_timeoutEditCtrl, 60] call btc_toolchain_enemy_waves_fnc_timeout_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_editGrp", controlNull, [controlNull]],
    ["_value", 60, [123, ""]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing timeout load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _edit = _editGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if(_value isEqualType 123) then {
	_value = str _value;
};
_edit ctrlSetText _value;
