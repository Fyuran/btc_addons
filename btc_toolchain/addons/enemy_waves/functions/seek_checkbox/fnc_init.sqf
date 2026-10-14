#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_seek_checkbox_init

Description:
    Initializes the seek end checkbox control in UI namespace.

Parameters:
    _checkboxGrp: CONTROL - The checkbox control group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:

Examples:
    (begin example)
        [_checkboxGrp] call btc_toolchain_enemy_waves_fnc_seek_checkbox_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkboxGrp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];

disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing seek end checkbox init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _checkbox = _checkboxGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _checkbox) exitWith {
    [["%1: _checkbox is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(seek_end), _checkbox];
