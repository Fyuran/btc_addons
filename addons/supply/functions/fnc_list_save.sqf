#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_list_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_list_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]]
];
disableSerialization;

private _table = missionNamespace getVariable[QGVAR(table), createHashMap];
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing attribute save with _value: %2", __FILE__, _table], 2, "supply"] call EFUNC(tools,debug);
#endif

toJSON _table;
