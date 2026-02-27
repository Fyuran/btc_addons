#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_list_save

Description:
    Encodes and returns the supply table data as JSON string for serialization.

Parameters:
    NONE

Returns:
    STRING: JSON encoded supply table data

Examples:
    (begin example)
        _jsonData = [] call btc_supply_fnc_list_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
private _table = missionNamespace getVariable[QGVAR(table), createHashMap];
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing list save with _value: %2 as JSON: %3", __FILE_NAME__, _table, toJSON _table], LOGS, "supply"] call EFUNC(tools,debug);
#endif

[_table] call CBA_fnc_encodeJSON;
