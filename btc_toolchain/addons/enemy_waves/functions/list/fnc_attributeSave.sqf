#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_attributeSave

Description:
    Encodes and returns table data as a JSON string for 3DEN attribute serialization.

Parameters:
    _main_grp: CONTROL or ARRAY - Main control group containing list displays

Returns:
    STRING - JSON encoded table data

Examples:
    (begin example)
        _jsonStr = [_listGrp] call btc_toolchain_enemy_waves_fnc_list_attributeSave;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]]
];

#ifdef BTC_DEBUG_SUPPLY
[["%1: executing list_grp attributeSave with %2", __FILE_NAME__, GVAR(table)], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

[GVAR(table)] call CBAFUNC(encodeJSON);
