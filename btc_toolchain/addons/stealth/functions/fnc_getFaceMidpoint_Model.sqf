#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_getFaceMidpoint_Model

Description:
    Computes the midpoint coordinate of a 4-vertex quadrilateral polygon face in model space.

Parameters:
    _face: ARRAY

Returns:
    ARRAY

Examples:
    (begin example)
        private _mid = [_facePoints] call btc_toolchain_stealth_fnc_getFaceMidpoint_Model;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_face", [], [[]], 4]
];

_face params[
    ["_p1", [], [[]], 3],
    ["_p2", [], [[]], 3],
    ["_p3", [], [[]], 3],
    ["_p4", [], [[]], 3]
];

[
    ((_p1 select 0) + (_p2 select 0) + (_p3 select 0) + (_p4 select 0)) / 4,
    ((_p1 select 1) + (_p2 select 1) + (_p3 select 1) + (_p4 select 1)) / 4,
    ((_p1 select 2) + (_p2 select 2) + (_p3 select 2) + (_p4 select 2)) / 4
]
