#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_spawnVehicle

Description:
    Spawns a supply transport aircraft with pilot and assigns ingress/egress waypoints.

Parameters:
    _logicPos: ARRAY - Target drop position [x, y, z]
    _vehicleClass: STRING - Aircraft vehicle class name
    _enableDamage: BOOL - Allow damage on the aircraft (default: true)

Returns:
    OBJECT - Created vehicle object

Examples:
    (begin example)
        private _veh = [_dropPos, "B_Heli_Transport_03_F", false] call btc_toolchain_supply_fnc_spawnVehicle;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logicPos", [0, 0, 0], [[]], 3],
    ["_vehicleClass", "", [""]],
    ["_enableDamage", true, [true]]
];

private _randomAngle = random 360;
private _isHelicopter = _vehicleClass isKindOf "Helicopter";
private _height = [PLANE_HEIGHT, AIR_HEIGHT] select _isHelicopter;
private _speed = [PLANE_SPEED, AIR_SPEED] select _isHelicopter;

private _vehPos = _logicPos vectorAdd [(cos _randomAngle) * 2000, (sin _randomAngle) * 2000, _height];
private _veh = createVehicle [_vehicleClass, _vehPos, [], 0, "FLY"];

private _logicPosDirection = _logicPos vectorDiff _vehPos;
_logicPosDirection = [_logicPosDirection#0, _logicPosDirection#1, 0];
_veh setVectorDir _logicPosDirection;
_veh setVelocityModelSpace [0, _speed, 10];
_veh allowDamage _enableDamage;

// Tag vehicle for debug tracking
_veh setVariable [QGVAR(isSupplyVehicle), true, true];
_veh setVariable [QGVAR(hasDroppedSupplies), false, true];
_veh setVariable [QGVAR(dropPos), _logicPos, true];

private _activeVehicles = missionNamespace getVariable [QGVAR(activeVehicles), []];
_activeVehicles pushBackUnique _veh;
missionNamespace setVariable [QGVAR(activeVehicles), _activeVehicles, true];

// Create pilot crew
private _grp = createGroup [civilian, true];
_grp setVariable ["acex_headless_blacklist", true];
private _pilot = _grp createUnit ["C_man_pilot_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_pilot assignAsDriver _veh;
_pilot moveInDriver _veh;

allCurators apply {
    _x addCuratorEditableObjects [[_veh], true];
};

// Assign waypoints (WP1: over drop target, WP2: egress path)
private _wp1 = _grp addWaypoint [[_logicPos#0, _logicPos#1, _height], 0];
_wp1 setWaypointBehaviour "CARELESS";

private _wp2 = _grp addWaypoint [_logicPos vectorAdd [(_logicPosDirection#0) * 10, (_logicPosDirection#1) * 10, _height], 0];
_wp2 setWaypointBehaviour "CARELESS";

_veh

