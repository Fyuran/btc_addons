#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_vectorLerp

Description:
    Performs linear interpolation between two 3D vectors by factor t (0 to 1).

Parameters:
    _vec1: ARRAY
    _vec2: ARRAY
    _t: NUMBER

Returns:
    ARRAY

Examples:
    (begin example)
        private _mid = [[0,0,0], [10,10,10], 0.5] call btc_toolchain_tools_fnc_vectorLerp;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
    ["_vec1", [0, 0], [[]], [2]],
    ["_vec2", [0, 0], [[]], [2]],
    ["_t", 0, [123]]
];

if(_t < 0) then {
    _t = 0;
};
if(_t > 1) then {
    _t = 1;
};

private _lerpVec = _vec1 vectorAdd((_vec2 vectorDiff _vec1) vectorMultiply _t);

_lerpVec
