#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_mouseMoving

Description:
    Handles mouse movement on the display to orbit the insignia camera when holding RMB.

Parameters:
    _xDelta: NUMBER - Mouse movement delta along X axis
    _yDelta: NUMBER - Mouse movement delta along Y axis

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params [
    ["_xDelta", 0, [123]],
    ["_yDelta", 0, [123]]
];

// State array: [_isHoldingRMB, _azimuth, _elevation, _distance]
private _state = uiNamespace getVariable [QGVAR(cameraState), []];
if (_state isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _state is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
_state params [
    ["_isHoldingRMB", false, [true]],
    ["_azimuth", 0, [123]],
    ["_elevation", 0, [123]]
];

// Check if holding RMB
if (!_isHoldingRMB) exitWith {};

_state set [1, _azimuth - _xDelta];
_state set [2, ((_elevation - _yDelta) min 45) max 0];
 
[] call FUNC(update);
