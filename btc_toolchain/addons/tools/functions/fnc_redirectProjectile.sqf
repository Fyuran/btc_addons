#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_redirectProjectile

Description:
    Redirects a fired projectile towards a target position.
    - For guided/unguided bombs (e.g. GBU-12, Mk82), actively guides the glide path
      to overcome heavy bomb drag and lack of propulsion, ensuring direct impact.
    - For self-propelled projectiles (missiles, rockets), directs them straight at
      the target with designated operational speed (zero drop compensation).
    - For ballistic projectiles (bullets, autocannon shells), calculates true parabolic
      gravity drop and air drag compensation.

Parameters:
    _projectile: OBJECT - Projectile to redirect
    _targetPosASL: OBJECT or ARRAY - Target object or 3D target position (ASL)
    _dispersion: NUMBER - Radius in meters for random circular spread (optional, default: 0)

Returns:
    BOOLEAN - True if successfully redirected, false otherwise

Examples:
    (begin example)
        [_projectile, _targetLogic] call btc_toolchain_tools_fnc_redirectProjectile;
        [_projectile, _targetPosASL, 5] call btc_toolchain_tools_fnc_redirectProjectile;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_projectile", objNull, [objNull]],
    ["_targetPosASL", [0, 0, 0], [objNull, []]],
    ["_dispersion", 0, [0]]
];

if (isNull _projectile) exitWith { false };

private _targetObj = if (_targetPosASL isEqualType objNull) then {
    if (isNull _targetPosASL) exitWith { objNull };
    _targetPosASL
} else {
    objNull
};

if (!isNull _targetObj) then {
    _targetPosASL = getPosASL _targetObj;
};

if (_targetPosASL isEqualTo [] || {_targetPosASL isEqualTo [0, 0, 0]}) exitWith {
    #ifdef BTC_DEBUG_TOOLS
    [["%1: invalid _targetPosASL", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
    #endif
    false
};

private _projPosASL = getPosASL _projectile;

// Optional dispersion around target (preserving ASL height)
private _aimPosASL = if (_dispersion > 0) then {
    private _angle = random 360;
    private _rad = sqrt (random 1) * _dispersion;
    _targetPosASL vectorAdd [_rad * cos _angle, _rad * sin _angle, 0]
} else {
    _targetPosASL
};

private _dist = _projPosASL distance _aimPosASL;
if (_dist < 1) exitWith { false };

// Query ammo configuration from CfgAmmo
private _ammoClass = typeOf _projectile;
private _ammoCfg = configFile >> "CfgAmmo" >> _ammoClass;

private _simulation = toLower getText (_ammoCfg >> "simulation");
private _thrust = getNumber (_ammoCfg >> "thrust");
private _maxSpeed = getNumber (_ammoCfg >> "maxSpeed");

private _isBomb = _ammoClass isKindOf ["BombCore", configFile >> "CfgAmmo"] || {_simulation isEqualTo "shotbomb"};
private _isRocket = _simulation isEqualTo "shotrocket" || {_ammoClass isKindOf ["RocketBase", configFile >> "CfgAmmo"]};
private _isMissile = !_isBomb && (_simulation isEqualTo "shotmissile" || {_ammoClass isKindOf ["MissileBase", configFile >> "CfgAmmo"]});
private _hasThrust = _thrust > 0 && {!_isBomb};

private _curVel = velocity _projectile;
private _speed = vectorMagnitude _curVel;

// 1. BOMBS (GBU-12, Mk82, etc.)
// Bombs have zero thrust and heavy drag (airFriction = 0.06). Actively guide glide path to target.
if (_isBomb) exitWith {
    _speed = _speed max 250;

    private _dir = _projPosASL vectorFromTo _aimPosASL;
    private _right = if (abs (_dir#2) > 0.99) then { [1, 0, 0] } else { vectorNormalized (_dir vectorCrossProduct [0, 0, 1]) };
    private _up = _right vectorCrossProduct _dir;

    _projectile setVectorDirAndUp [_dir, _up];
    _projectile setVelocity (_dir vectorMultiply _speed);

    // Active glide guidance loop until bomb impact
    [{
        params ["_args", "_handle"];
        _args params ["_projectile", "_targetObj", "_aimPosASL", "_speed"];

        if (isGamePaused) exitWith {};

        if (!alive _projectile) exitWith {
            [_handle] call CBAFUNC(removePerFrameHandler);
        };

        private _destPosASL = if (!isNull _targetObj) then {
            getPosASL _targetObj
        } else {
            _aimPosASL
        };

        private _pos = getPosASL _projectile;
        if (_pos distance _destPosASL < 2) exitWith {
            [_handle] call CBAFUNC(removePerFrameHandler);
        };

        private _dir = _pos vectorFromTo _destPosASL;
        private _right = if (abs (_dir#2) > 0.99) then { [1, 0, 0] } else { vectorNormalized (_dir vectorCrossProduct [0, 0, 1]) };
        private _up = _right vectorCrossProduct _dir;

        _projectile setVectorDirAndUp [_dir, _up];
        _projectile setVelocity (_dir vectorMultiply _speed);
    }, 0, [_projectile, _targetObj, _aimPosASL, _speed]] call CBAFUNC(addPerFrameHandler);

    true
};

// 2. MISSILES & ROCKETS (Self-propelled)
// Aim directly at target (zero drop compensation) with operational speed
if (_hasThrust || _isMissile || _isRocket) exitWith {
    if (_maxSpeed > 0) then {
        _speed = _maxSpeed;
    };
    _speed = _speed max 500;

    private _dir = _projPosASL vectorFromTo _aimPosASL;
    private _right = if (abs (_dir#2) > 0.99) then { [1, 0, 0] } else { vectorNormalized (_dir vectorCrossProduct [0, 0, 1]) };
    private _up = _right vectorCrossProduct _dir;

    _projectile setVectorDirAndUp [_dir, _up];
    _projectile setVelocity (_dir vectorMultiply _speed);

    true
};

// 3. BALLISTIC ROUNDS (Autocannon shells, Gatling, bullets)
// Calculate parabolic arc elevation to compensate for gravity drop and drag
if (_speed < 100) then {
    private _typical = getNumber (_ammoCfg >> "typicalSpeed");
    if (_typical > 0) then { 
        _speed = _typical; 
    };
};
_speed = _speed max 400;

private _timeToTarget = _dist / _speed;

private _airFriction = abs (getNumber (_ammoCfg >> "airFriction"));
if (_airFriction > 0) then {
    _timeToTarget = _timeToTarget * (1 + _airFriction * _dist * 0.5);
};

private _gravityDrop = (0.5 * 9.81 * (_timeToTarget ^ 2)) min (_dist * 0.5);
private _elevatedAimPosASL = _aimPosASL vectorAdd [0, 0, _gravityDrop];

private _dir = _projPosASL vectorFromTo _elevatedAimPosASL;
private _right = if (abs (_dir#2) > 0.99) then { [1, 0, 0] } else { vectorNormalized (_dir vectorCrossProduct [0, 0, 1]) };
private _up = _right vectorCrossProduct _dir;

_projectile setVectorDirAndUp [_dir, _up];
_projectile setVelocity (_dir vectorMultiply _speed);

true
