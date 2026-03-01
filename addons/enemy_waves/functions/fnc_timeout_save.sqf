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
[["%1: executing timeout save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

parseNumber(ctrlText _edit);
