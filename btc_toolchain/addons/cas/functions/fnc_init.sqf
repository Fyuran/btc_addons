#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_init

Description:
    Commands an air unit to spawn a CAS.

Parameters:
    _logic: OBJECT - Module logic entity
    _units: ARRAY - List of affected units
    _activated: BOOLEAN - Module activation state

Returns:
    NOTHING

Examples:
    (begin example)
        [_logic, [], true] call btc_toolchain_cas_fnc_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!canSuspend) exitWith {
    _this spawn FUNC(init);
};
if (!isServer) exitWith {
    [["%1: attempted to call %2 as client", __FILE_NAME__, QFUNC(drop)], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (!_activated) exitWith {};
if (isNull _logic) exitWith {
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _vehicleData = _logic getVariable [QGVAR(vehicleData), createHashMap];
if (_vehicleData isEqualType "") then {
    _vehicleData = fromJSON _vehicleData;
};
if (_vehicleData isEqualTo createHashMap) exitWith {
    [["%1: empty vehicle data has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (isNil "_vehicleData") exitWith {
    [["%1: _vehicleData is nil", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _vehicleClass = _vehicleData getOrDefault ["class", ""];
if (_vehicleClass isEqualTo "") exitWith {
    [["%1: empty vehicle class has been passed to %2, listData = %3", __FILE_NAME__, _logic, _vehicleData], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (!isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {
    [["%1: bad vehicle class '%2' has been passed to %3", __FILE_NAME__, _vehicleClass, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _enableDamage = _logic getVariable [QGVAR(enableDamage), true];
private _spawnDistance = _logic getVariable [QGVAR(distance), 3000];
private _spawnHeight = _logic getVariable [QGVAR(height), 2000];

// Spawn vehicle and crew
private _debug = _logic getVariable [QGVAR(debug), false];
([_logic, _vehicleClass, _enableDamage, _spawnDistance, _spawnHeight, _debug] call FUNC(vehicle_spawn)) params [
    ["_veh", objNull, [objNull]], 
    ["_group", grpNull, [grpNull]]
];
if (isNull _veh) exitWith {
    [["%1: failed to spawn vehicle %2", __FILE_NAME__, _vehicleClass], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (_debug) then {
    GVAR(veh) = _veh;
    [_veh] call FUNC(debug);
};

if (_logic getVariable [QGVAR(remoteControl), false]) exitWith {
    private _synchedObjects = synchronizedObjects _logic;
    private _synchedPlayers = _synchedObjects select { isPlayer _x };
    if (_synchedPlayers isEqualTo []) then { //try again
        _synchedPlayers = _logic getVariable [QGVAR(curatorUnits), []];
    };
    if (_synchedPlayers isNotEqualTo []) then {
        #ifdef BTC_DEBUG_CAS
        [["%1: remoteControl is enabled, leaving controls to user", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        private _owner = owner (_synchedPlayers#0);
        private _showMarker = _logic getVariable [QGVAR(remoteHelper), false];

        _logic setVariable [QGVAR(remoteHelper), _showMarker, _owner];
        [_veh, _logic] remoteExecCall [QFUNC(vehicle_remoteControl), _owner];
    } else {
        [["%1: Remote Control enabled but no synched players found, synched players found: %2", __FILE_NAME__, _synchedPlayers], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        deleteVehicle _veh;
        deleteVehicle _logic;
    };
};

private _weapons = _vehicleData getOrDefault ["listData", []];
if (_weapons isEqualTo []) exitWith {
    [["%1: no weapons selected", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_veh setVariable [QGVAR(weapons), _weapons]; //used by FUNC(vehicle_fire)

private _logicPos = getPos _logic;
_logicPos set [2, 0]; //height reset at 0
private _wp1 = _group addWaypoint [_logicPos, 0];
_wp1 setWaypointBehaviour "CARELESS";
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "FULL";
private _triggerDistance = _logic getVariable [QGVAR(triggerDistance), 1500];
_wp1 setWaypointCompletionRadius _triggerDistance;
_veh setSpeedMode "FULL";

//SQUARED distance
private _triggerDistanceSqr = _triggerDistance * _triggerDistance;
waitUntil {
    (_veh distanceSqr _logicPos) <= _triggerDistanceSqr
};

_veh setVariable [QGVAR(logic), _logic, true];
[_veh, _logic, {}, FUNC(vehicle_fire), {deleteVehicle (_this#1)}, _logic getVariable [QGVAR(duration), 15], _debug] call FUNC(vehicle_dive);
