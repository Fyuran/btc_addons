#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_getCentroid

Description:
    Calculates the geometric centroid (arithmetic mean) of an array of 3D positions.

Parameters:
    _positions: ARRAY
    _useZ: BOOLEAN

Returns:
    ARRAY

Examples:
    (begin example)
        private _center = [_posArray, false] call btc_toolchain_stealth_fnc_getCentroid;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_positions", [], [[]]],
    ["_useZ", false, [true]]
];

if(_positions isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: _positions is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _z = 0;
if(_useZ) then {
    _z = (_positions apply { _x select 2 }) call BIS_fnc_arithmeticMean;
};
private _centroid = [
    (_positions apply { _x select 0 }) call BIS_fnc_arithmeticMean,
    (_positions apply { _x select 1 }) call BIS_fnc_arithmeticMean,
    _z
];

_centroid
