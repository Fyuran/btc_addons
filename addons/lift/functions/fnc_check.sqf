#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_lift_fnc_check

Description:
    Performs check if cargo can be lifted

Parameters:
    _chopper - [Object]

Returns:

Examples:
    (begin example)
        _result = [] call btc_toolchain_lift_fnc_check;
    (end)

Author:
    Giallustio, Fyuran

---------------------------------------------------------------------------- */

params [
    ["_chopper", vehicle player, [objNull]]
];

if (
    !(_chopper isKindOf "Helicopter" || (_chopper isKindOf "Ship")) ||
    !isNull (_chopper getVariable ["cargo", objNull]) ||
    !(missionNamespace getVariable [QGVAR(ropes_deployed), false])
) exitWith {false};

private _array = [_chopper] call FUNC(getLiftable);
if (_array isEqualTo []) exitWith {false};

private _cargo_array = nearestObjects [_chopper, _array, 30];
_cargo_array = _cargo_array - [_chopper];
_cargo_array = _cargo_array select {!(
    _x isKindOf "ACE_friesBase" OR
    _x isKindOf "ace_fastroping_helper"
)};

if (_cargo_array isEqualTo []) exitWith {false};
private _cargo = _cargo_array select 0;

private _can_lift = (_array findIf {_cargo isKindOf _x} != -1) && speed _cargo < 5;

if !(_can_lift) exitWith {false};

private _cargo_pos = getPosATL _cargo;
(_chopper worldToModel _cargo_pos) params ["_cargo_x", "_cargo_y"];
private _cargo_z   = ((getPosATL _chopper) select 2) - (_cargo_pos select 2);

private _can_lift = ((abs _cargo_z) < BTC_LIFT_MAX_H) && ((abs _cargo_z) > BTC_LIFT_MIN_H) && ((abs _cargo_x) < BTC_LIFT_RADIUS) && ((abs _cargo_y) < BTC_LIFT_RADIUS);

_can_lift
