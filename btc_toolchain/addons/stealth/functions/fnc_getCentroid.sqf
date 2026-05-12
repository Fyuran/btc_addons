#include "..\script_component.hpp"

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
