#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_enemy_waves_fnc_list_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
private _table = missionNamespace getVariable[QGVAR(table), []];
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing list save with _value: %2 as JSON: %3", __FILE_NAME__, _table, [_table] call CBAFUNC(encodeJSON)], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

str _table
