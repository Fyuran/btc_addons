#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_presets_applyData

Description:
    Applies loaded preset attributes to the cas dialog controls.

Parameters:
    _preset: HASHMAP - Loaded preset data

Returns:
    NOTHING

Examples:
    (begin example)
        [_presetData] call btc_toolchain_cas_fnc_presets_applyData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_preset", createHashMap, [createHashMap]]
];
