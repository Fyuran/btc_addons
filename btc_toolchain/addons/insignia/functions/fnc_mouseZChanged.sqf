#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_mouseZChanged

Description:
    Handles mouse wheel zoom for the insignia inspection camera.

Parameters:
    _zChange: NUMBER - Mouse wheel scroll delta

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params [
    ["_zChange", 0, [123]]
];

// State array: [_isHoldingRMB, _azimuth, _elevation, _distance]
private _state = uiNamespace getVariable [QGVAR(cameraState), []];
if (_state isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _state is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

#ifdef BTC_DEBUG_INSIGNIA
[["%1: MouseZChanged _this: %2", __FILE_NAME__, _this], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

_state params [
    ["_isHoldingRMB", false, [true]],
    ["_azimuth", 0, [123]],
    ["_elevation", 0, [123]],
    ["_distance", 0, [123]]
];
// Scrolling up (_zChange > 0) zooms in (decreases distance)
private _dist = _distance - (_zChange * 0.08);
_dist = (_dist max 0.15) min 3.0;
_state set [3, _dist];

[] call FUNC(update);
