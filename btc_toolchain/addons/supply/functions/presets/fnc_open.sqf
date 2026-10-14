#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_presets_open

Description:
    Opens supply presets window.

Parameters:
    _presetsBtn: CONTROL - Presets button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_presetsBtn] call btc_toolchain_supply_fnc_presets_open;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_presetsBtn", controlNull, [controlNull]]
];

[_presetsBtn, QGVAR(savedPresets), FUNC(presets_gatherData), FUNC(presets_applyData)] call EFUNC(gui,presets_open);
