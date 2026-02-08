#include "..\script_component.hpp"
#define UPDATE_RATE 0.1
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_windSmoothTrans

Description:
    Handles wind vector interpolation between old position, setWind original syntax where you
    define [x, y, forced] array does not allow you to transition smoothly, this function solves that with
    a fixed update rate

Parameters:
    _duration: how long will the transition last
    _plannedIntensity: how strong will the wind be
Returns:

Examples:
    (begin example)
	[] call r4efu2s3qw;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
    ["_duration", 10, [123]],
    ["_plannedIntesity", 20, [123]]
];

private _currentTime = 0;    
private _currentWind = [wind#0, wind#1];
private _plannedWindVector = [0, random[-0.5, -0.8, -1]] vectorMultiply (random _plannedIntesity);
while{_currentTime < _duration} do {
    private _linearTime = linearConversion[0, _duration, _currentTime, 0, 1, true];
    private _intervalVector = [_currentWind, _plannedWindVector, _linearTime] call EFUNC(tools,vectorLerp);
    setWind[_intervalVector#0, _intervalVector#1, true];
    _currentTime = _currentTime + UPDATE_RATE;
    #ifdef BTC_DEBUG_SNOWSTORM
    [["%1: _currentTime: %2, _duration: %3,  _linearTime: %4,
            _plannedWindVector: %5, intervalVec: %6", __FILE__, 
        _currentTime, _duration, _linearTime, _plannedWindVector, _intervalVector], 2, "snowstorm"] call EFUNC(tools,debug);
    #endif
    sleep UPDATE_RATE;
};
