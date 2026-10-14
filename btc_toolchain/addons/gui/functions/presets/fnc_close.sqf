#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_presets_close

Description:
    Closes the presets menu

Parameters:
    _close: CONTROL - The close button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_closeButton] call btc_toolchain_gui_fnc_presets_close;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_close", controlNull, [controlNull]]
];
disableSerialization;

private _presets = ctrlParent _close;
_presets closeDisplay 1;
