#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_update

Description:
    Updates the inspection camera position and orientation around the target.

Parameters:

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */

private _cam = uiNamespace getVariable [QGVAR(camera), objNull];
if (isNull _cam) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _cam is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if (isNull _cam || {!alive player}) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _cam is null or player is not alive", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _state = uiNamespace getVariable [QGVAR(cameraState), []];
if (_state isEqualTo []) exitWith {};

_state params [
    ["_isHoldingRMB", false, [true]],
    ["_azimuth", 0, [123]],
    ["_elevation", 0, [123]],
    ["_distance", 0, [123]]
];

private _camVector = [
    (cos _elevation) * (sin _azimuth), 
    (cos _elevation) * (cos _azimuth), 
    sin _elevation
] vectorMultiply _distance;
        
_cam camSetRelPos _camVector;
_cam camCommit 0.1;   
