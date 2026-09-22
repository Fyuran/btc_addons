#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_deployable_antenna_fnc_dismantle

Description:
    Dismantles a deployed antenna object, removing it from the world and returning the item to player inventory.

Parameters:
    _player: OBJECT
    _object: OBJECT

Returns:

Examples:
    (begin example)
        [player, cursorObject] call btc_toolchain_deployable_antenna_fnc_dismantle;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

[_this, {
    params[
        ["_player", objNull, [objNull]],
        ["_object", objNull, [objNull]]
    ];
    if!(_object isKindOf "Land_SatelliteAntenna_01_F") exitWith {};

    deleteVehicle _object;
    _player addItem QGVAR(DeployableAntenna);

}] remoteExecCall["call", [0, 2] select isMultiplayer];
