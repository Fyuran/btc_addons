#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_curator_init

Description:
    Initializes the supply module when synced with a Zeus curator.

Parameters:
    _logic: OBJECT
    _units: ARRAY
    _activated: BOOLEAN

Returns:
    NOTHING

Examples:
    (begin example)
        [_logic, [], true] call btc_toolchain_supply_fnc_curator_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

missionNamespace setVariable [QGVAR(logic), _logic, owner _logic];
[_logic, _activated, FUNC(curator_OKCode)] call EFUNC(gui,curator_init);
