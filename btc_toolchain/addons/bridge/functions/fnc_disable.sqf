#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_disable

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_disable;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_display", displayNull, [displayNull]]
];

if(isNull _display) exitWith {
	[["%1: _display is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_display displayRemoveEventHandler["KeyDown", GVAR(keyDown_handle)];
_display displayRemoveEventHandler["MouseZChanged", GVAR(MouseZChanged_handle)];
_display displayRemoveEventHandler["MouseMoving", GVAR(MouseMoving_handle)];
_display displayRemoveEventHandler["Unload", GVAR(onUnload_handle)];

if(isNull GVAR(vehicle)) exitWith {
	[["%1: GVAR(vehicle) is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
GVAR(vehicle) setVariable[QGVAR(segments), []];
GVAR(vehicle) = objNull;
btc_camera cameraEffect ["terminate", "back"];
camDestroy btc_camera;
