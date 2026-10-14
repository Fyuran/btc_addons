#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_timeout_init

Description:
    Initializes wave timeout edit box control with default delay value.

Parameters:
    _editGrp: CONTROL - Timeout edit box control group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:

Examples:
    (begin example)
        [_editGrp] call btc_toolchain_enemy_waves_fnc_timeout_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_editGrp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];

disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing timeout init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _edit = _editGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _edit) exitWith {
    [["%1: _edit is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(timeout), _edit];

_edit ctrlSetText "60";
