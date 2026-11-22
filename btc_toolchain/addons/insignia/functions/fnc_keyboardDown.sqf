#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_keyboardDown

Description:
    Handles keyboard events for the insignia inspection camera.
    Toggles night vision mode when the NVG key is pressed.

Parameters:
    _key: NUMBER - Key code (DIK_N)

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */

params [
    ["_key", -1, [123]]
];

if (_key isNotEqualTo DIK_N || {(hmd player) isEqualTo ""}) exitWith {};

#ifdef BTC_DEBUG_INSIGNIA
[["%1: KeyDown _this: %2", __FILE_NAME__, _this], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _isUsingNvg = uiNamespace getVariable [QGVAR(nvg), false];
_isUsingNvg = !_isUsingNvg; //flip the state

uiNamespace setVariable [QGVAR(nvg), _isUsingNvg];
camUseNVG _isUsingNvg;
