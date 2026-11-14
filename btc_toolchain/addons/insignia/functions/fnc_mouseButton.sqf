#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_mouseButton

Description:
    Handles mouse button events for the insignia inspection camera.
    Toggles orbiting mode when RMB is held down.

Parameters:
    _button: NUMBER - Mouse button code (MOUSE_RMB = 1)
    _bool: BOOLEAN - True if button is down, false if released

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params [
    ["_button", -1, [123]],
    ["_bool", false, [true]]
];

if (_button isNotEqualTo MOUSE_RMB) exitWith {};

#ifdef BTC_DEBUG_INSIGNIA
[["%1: MouseButton%2 _this: %3", __FILE_NAME__, ["Up", "Down"] select _bool, _this], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

// State array: [_isHoldingRMB, _azimuth, _elevation, _distance]
private _state = uiNamespace getVariable [QGVAR(cameraState), []];
if (_state isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _state is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

_state set [0, _bool];
