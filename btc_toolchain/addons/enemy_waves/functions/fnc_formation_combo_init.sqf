#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_formation_combo_init

Description:
    Initializes formation combo control in enemy waves dialog and loads default COLUMN formation.

Parameters:
    _combo: CONTROL

Returns:

Examples:
    (begin example)
        [_formationCombo] call btc_toolchain_enemy_waves_fnc_formation_combo_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_combo", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
uiNamespace setVariable[QGVAR(formation_combo), _combo];

[_combo, "COLUMN"] call btc_toolchain_enemy_waves_fnc_formation_combo_load;
