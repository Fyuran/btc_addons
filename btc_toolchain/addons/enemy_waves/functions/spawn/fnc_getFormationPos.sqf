#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_spawn_getFormationPos

Description:
    Calculates the 3D world position ATL for a unit at a given group index
    according to a specified tactical formation, anchored at a center position
    and facing direction.

Parameters:
    _anchorPos: ARRAY - Origin position [x, y, z]
    _dir: NUMBER - Compass heading direction in degrees
    _formation: STRING - Formation type ('wedge','vee','line','column','file','stag_column','ech_left','ech_right','diamond')
    _index: NUMBER - 0-based index of the unit in the formation (0 is leader)
    _spacing: NUMBER - Distance in meters between units (optional, default 5)

Returns:
    ARRAY - 3D position [x, y, z] ATL

Examples:
    (begin example)
        private _pos = [getPosATL _logic, getDir _logic, "wedge", 1, 5] call btc_toolchain_enemy_waves_fnc_spawn_getFormationPos;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_anchorPos", [0, 0, 0], [[]], [2, 3]],
    ["_dir", 0, [0]],
    ["_formation", "wedge", [""]],
    ["_index", 0, [0]],
    ["_spacing", 5, [0]]
];

if (_index <= 0) exitWith {
    [(_anchorPos select 0), (_anchorPos select 1), 0]
};

private _relPos = [0, 0];

switch (_formation) do {
    case "wedge": {
        private _rank = ceil (_index / 2);
        private _side = if (_index % 2 == 1) then { 1 } else { -1 };
        _relPos = [_side * _rank * _spacing, -_rank * _spacing];
    };
    case "vee": {
        private _rank = ceil (_index / 2);
        private _side = if (_index % 2 == 1) then { 1 } else { -1 };
        _relPos = [_side * _rank * _spacing, _rank * _spacing];
    };
    case "line": {
        private _rank = ceil (_index / 2);
        private _side = if (_index % 2 == 1) then { 1 } else { -1 };
        _relPos = [_side * _rank * _spacing, 0];
    };
    case "column": {
        private _rank = ceil (_index / 2);
        private _side = if (_index % 2 == 1) then { 0.5 } else { -0.5 };
        _relPos = [_side * _spacing, -_rank * _spacing];
    };
    case "file": {
        _relPos = [0, -_index * _spacing];
    };
    case "stag_column": {
        private _side = if (_index % 2 == 1) then { -0.5 } else { 0.5 };
        _relPos = [_side * _spacing, -_index * _spacing];
    };
    case "ech_left": {
        _relPos = [-_index * _spacing, -_index * _spacing];
    };
    case "ech_right": {
        _relPos = [_index * _spacing, -_index * _spacing];
    };
    case "diamond": {
        private _ring = ceil (_index / 3);
        private _slot = (_index - 1) % 3;
        _relPos = switch (_slot) do {
            case 0: { [-_ring * _spacing, -_ring * _spacing] };
            case 1: { [_ring * _spacing, -_ring * _spacing] };
            case 2: { [0, -_ring * 2 * _spacing] };
        };
    };
    default {
        _relPos = [0, 0];
    };
};

_relPos params ["_relX", "_relY"];

private _worldX = (_anchorPos select 0) + (_relX * cos _dir + _relY * sin _dir);
private _worldY = (_anchorPos select 1) + (-_relX * sin _dir + _relY * cos _dir);

[_worldX, _worldY, 0]

