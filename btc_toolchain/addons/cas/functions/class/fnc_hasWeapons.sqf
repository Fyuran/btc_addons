#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_class_hasWeapons

Description:
    Handles class predicate callback

Parameters:
    _config: CONFIG

Returns:
    BOOLEAN

Examples:
    (begin example)
        [] call btc_toolchain_cas_fnc_class_hasWeapons;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_config", configNull, [configNull]]
];

private _class = configName _config;
([_class] call EFUNC(tools,getVehicleWeaponsData)) isNotEqualTo []
