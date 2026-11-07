#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_vehicle_spawn

Description:
    Spawns a CAS vehicle.

Parameters:
    _logic: OBJECT - Logic
    _vehicleClass: STRING - Aircraft vehicle class name
    _enableDamage: BOOLEAN - Allow damage on the aircraft (default: true)
    _spawnDistance: NUMBER - How far will vehicle spawn
    _spawnHeight: NUMBER - How up in the sky will vehicle spawn

Returns:
    ARRAY

Examples:
    (begin example)
        private _veh = [_dropPos, "B_Heli_Transport_03_F", false] call btc_toolchain_cas_fnc_vehicle_spawn;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logic", objNull, [objNull]],
    ["_vehicleClass", "", [""]],
    ["_enableDamage", true, [true]],
    ["_spawnDistance", 3000, [123]],
    ["_spawnHeight", 2000, [123]],
    ["_debug", false, [true]]
];

private _logicPos = getPos _logic;
_logicPos set [2, 0]; //height reset at 0

private _isHelicopter = _vehicleClass isKindOf "Helicopter";
private _speed = [100, 30] select _isHelicopter;

private _spawnPos = ((vectorDir _logic) vectorMultiply -1) vectorMultiply _spawnDistance;
private _vehPos = _logicPos vectorAdd [_spawnPos#0, _spawnPos#1, _spawnHeight];
private _veh = ([_vehPos, 0, _vehicleClass] call EFUNC(tools,spawnCrewedVehicle)) select 0;
if (_debug) then {
    private _vehDebugPos = missionNamespace getVariable [QGVAR(debugVehsPos), []];
    _vehDebugPos pushBack _vehPos;
    missionNamespace setVariable [QGVAR(debugVehsPos), _vehDebugPos];
    _veh setVariable [QGVAR(debugPos), _vehPos];
};
private _group = group _veh;
allCurators apply {
    _x addCuratorEditableObjects [[_veh], true];
};

private _logicPosDirection = _logicPos vectorDiff _vehPos;
_logicPosDirection = [_logicPosDirection#0, _logicPosDirection#1, 0];
_veh setVectorDir _logicPosDirection;
_veh setVelocityModelSpace [0, _speed, 10];
_veh allowDamage _enableDamage;

[_veh, _group]
