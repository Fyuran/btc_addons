#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_deployable_antenna_fnc_dismantle

Description:
    Dismantles a 'Land_SatelliteAntenna_01_F' object into a 'Deployable_antenna_Item'

Parameters:

Returns:

Examples:
    (begin example)
        [cursorObject] call btc_deployable_antenna_fnc_dismantle;
    (end)

Author:
    Fyuran

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
