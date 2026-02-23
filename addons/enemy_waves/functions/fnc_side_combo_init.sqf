#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_side_combo_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_side_combo_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo init", __FILE_NAME__], LOGS, "enemy_waves"] call EFUNC(tools,debug);
#endif
uiNamespace setVariable[QGVAR(side_combo), _combo];

[_combo, 0] call FUNC(side_combo_load);
