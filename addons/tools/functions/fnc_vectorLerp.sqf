#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_tools_fnc_vectorLerp

Description:
    Handles vector interpolation v = v1 + (v2 - v1) * t

Parameters:
    _vec1: From
    _vec2: To
    _t: time interval 0 to 1
Returns:

Examples:
    (begin example)
	[[1,0], [0,1], 0.5] call btc_tools_fnc_vectorLerp;
    (end)

Author:
    Fyuran

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
