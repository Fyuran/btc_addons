#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_timeout_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_timeout_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_edit", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing timeout init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
uiNamespace setVariable[QGVAR(timeout), _edit];

[_edit, 60] call btc_enemy_waves_fnc_timeout_load;
