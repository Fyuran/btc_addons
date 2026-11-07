#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_vehicle_dive

Description:
    Commands an aircraft to perform a precision CAS dive attack along a Bézier curve.
    When attacking as a helicopter, pitches the nose downwards further than the flight
    path tangent to ensure weapon delivery strikes directly within the target area.

Parameters:
    _veh: OBJECT - Aircraft to perform the dive
    _logic: OBJECT - Target object to dive towards
    _onBegin: CODE - Code block executed upon dive beginning [_veh, _logic] (optional, default: {})
    _onFrame: CODE - Code block executed upon dive frame while pointing at target prior to pull-up [_veh, _targetPosASL, _t, _logic] (optional, default: {})
    _onComplete: CODE - Code block executed upon dive completion [_veh, _logic] (optional, default: {})
    _duration: NUMBER
    _debug: BOOLEAN - Show debug informations

Returns:
    NOTHING

Examples:
    (begin example)
        [_plane, _targetPos] call btc_toolchain_cas_fnc_vehicle_dive;
        [_plane, _targetObj, {}, FUNC(vehicle_fire), {}] call btc_toolchain_cas_fnc_vehicle_dive;
        [_heli, _targetObj, {}, FUNC(vehicle_fire), {}, 12] call btc_toolchain_cas_fnc_vehicle_dive;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_veh", objNull, [objNull]],
    ["_logic", objNull, [objNull]],
    ["_onBegin", {}, [{}]],
    ["_onFrame", {}, [{}]],
    ["_onComplete", {}, [{}]],
    ["_duration", 10, [123]],
    ["_debug", false, [true]]
];

private _isHelicopter = _veh isKindOf "Helicopter";
private _pitchDown = [5, 10] select _isHelicopter;
private _speed = [100, 30] select _isHelicopter;

private _startPosASL = getPosASL _veh;
private _logicPosASL = getPosASL _logic;

private _startToLogicASL = _logicPosASL vectorDiff _startPosASL;
private _endPosASL = _logicPosASL vectorAdd [_startToLogicASL#0, _startToLogicASL#1, _startPosASL#2];
private _endPosTerrainHeight = getTerrainHeightASL _endPosASL;
_endPosASL = _endPosASL vectorAdd [0, 0, _endPosTerrainHeight]; //Add extra height so the vehicle doesn't crash into the bloody mountains

private _logicToEndASL = _endPosASL vectorDiff _logicPosASL;

// will show an approximate path
if (_debug) then {
    [_startPosASL, _logicPosASL, _endPosASL, 0.01, _debug] call EFUNC(tools,calculateBezier);
};

private _wp = (group _veh) addWaypoint [_endPosASL vectorAdd ((vectorNormalized _logicToEndASL) vectorMultiply worldSize), 0];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "FULL";
_wp setWaypointStatements ["true", QUOTE(_veh = objectParent this; deleteVehicleCrew _veh; deleteVehicle _veh;)];

_veh disableAI "MOVE";
_veh disableAI "PATH";

[_veh, _logic] call _onBegin;

private _startTimer = CBA_missionTime;
private _endTimer = _startTimer + _duration;

//Redirect projectiles to logic pos
_veh addEventHandler ["Fired", {
    params [
        ["_veh", objNull, [objNull]], 
        ["_weapon", "", [""]], 
        ["_muzzle", "", [""]],
        ["_mode", "", [""]],
        ["_ammo", "", [""]],
        ["_magazine", "", [""]],
        ["_projectile", objNull, [objNull]],
        ["_gunner", objNull, [objNull]]
    ];

    private _logic = _veh getVariable [QGVAR(logic), objNull];
    if (isNull _logic) exitWith {
        #ifdef BTC_DEBUG_CAS
        [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
    };

    private _debug = _logic getVariable [QGVAR(debug), false];
    if (_debug) then {
        private _ammos = missionNamespace getVariable [QGVAR(debugAmmo), []];
        _ammos pushBack _projectile;
        missionNamespace setVariable [QGVAR(debugAmmo), _ammos];
    };

    private _dispersion = _logic getVariable [QGVAR(dispersion), 10];
    [_projectile, _logic, _dispersion] call EFUNC(tools,redirectProjectile);
}];

[{
    params ["_args", "_thisHandle"];
    _args params [
        ["_veh", objNull, [objNull]],
        ["_startTimer", 0, [123]],
        ["_endTimer", 1, [123]],
        ["_startPosASL", [0, 0, 0], [[]], 3],
        ["_logicPosASL", [0, 0, 0], [[]], 3],
        ["_endPosASL", [0, 0, 0], [[]], 3],
        ["_startToLogicASL", [0, 0, 0], [[]], 3],
        ["_logicToEndASL", [0, 0, 0], [[]], 3],
        ["_speed", 100, [123]],
        ["_logic", objNull, [objNull]],
        ["_onFrame", {}, [{}]],
        ["_onComplete", {}, [{}]]
    ];

    if (isGamePaused) exitWith {};
    
    if (!alive _veh) exitWith {
        [_thisHandle] call CBAFUNC(removePerFrameHandler);
        [objNull, _logic] call _onComplete;
    };

    private _t = linearConversion [_startTimer, _endTimer, CBA_missionTime, 0, 1, true];
    if (_t >= 1) exitWith {
        _veh setVariable [QGVAR(pathIndex), nil];
        _veh enableAI "MOVE";
        _veh enableAI "PATH";
        private _originalHeight = _startPosASL#2;
        _veh flyInHeightASL [_originalHeight, _originalHeight, _originalHeight];

        [_veh, _logic] call _onComplete;
        [_thisHandle] call CBAFUNC(removePerFrameHandler);
    };

    private _p0 = _startPosASL vectorAdd (_startToLogicASL vectorMultiply _t);
    private _p1 = _logicPosASL vectorAdd (_logicToEndASL vectorMultiply _t);
    private _dir = _p0 vectorFromTo _p1;
    private _right = _dir vectorCrossProduct [0, 0, 1];
    private _up = _right vectorCrossProduct _dir;
    private _velocity = _dir vectorMultiply _speed;

    _veh setVelocityTransformation [
        _p0,
        _p1,
        _velocity,
        _velocity,
        _dir,
        _dir,
        _up,
        _up,
        _t
    ];

    private _dotProduct = _dir vectorDotProduct (_p0 vectorFromTo _logicPosASL);
    if ((abs _dotProduct) >= 0.98) then {
        [_veh, _logic] call _onFrame;
    };
}, 0, [_veh, _startTimer, _endTimer, _startPosASL, _logicPosASL, _endPosASL, _startToLogicASL, _logicToEndASL, _speed, _logic, _onFrame, _onComplete]] call CBAFUNC(addPerFrameHandler);
