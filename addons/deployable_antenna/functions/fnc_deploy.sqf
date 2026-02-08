#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_deployable_antenna_fnc_deploy

Description:
    Deploys a Land_SatelliteAntenna_01_F removing the item from the inventory

Parameters:

Returns:

Examples:
    (begin example)
        [player] call btc_deployable_antenna_fnc_deploy;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

[_this, {
    params[
        ["_player", objNull, [objNull]]
    ];
    _player removeItem QGVAR(DeployableAntenna);

    private _objectRelPos = ((getPos _player) vectorAdd ((vectorNormalized vectorDir _player) vectorMultiply 3));

    private _obj = createVehicle ["Land_SatelliteAntenna_01_F", [0,0,0], [], 0, "CAN_COLLIDE"];
    _obj setVectorDir ((_objectRelPos) vectorFromTo (getPos _player));
    _obj setPos _objectRelPos;

    [_obj] spawn {
        params[
            ["_obj", objNull, [objNull]]
        ];
        while {alive _obj} do {
            [_obj, QGVAR(Jammer_Sound)] remoteExecCall ["say3D", [0, -2] select isDedicated];
            sleep 28;
        };  
    };
}] remoteExecCall["call", [0, 2] select isMultiplayer];
