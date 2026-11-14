#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_destroyCamera

Description:
    Destroys the insignia inspection camera and removes attached event handlers.

Parameters:

Returns:
    NOTHING

Examples:
    (begin example)
        call btc_toolchain_insignia_fnc_destroyCamera;
    (end)
    (begin example)
        _cam call btc_toolchain_insignia_fnc_destroyCamera;
    (end)

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */

private _cam = uiNamespace getVariable [QGVAR(camera), objNull];
if (isNull _cam) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
    [["%1: _cam is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

// Remove display event handlers
private _display = uiNamespace getVariable [QGVAR(cameraDisplay), displayNull];
private _handlers = uiNamespace getVariable [QGVAR(cameraHandlers), []];
if (!isNull _display && {_handlers isNotEqualTo []}) then {
    _handlers params [
        ["_ehDown", -1, [123]], 
        ["_ehUp", -1, [123]],
        ["_ehMove", -1, [123]], 
        ["_ehWheel", -1, [123]]
    ];

    _display displayRemoveEventHandler ["MouseButtonDown", _ehDown];
    _display displayRemoveEventHandler ["MouseButtonUp", _ehUp];
    _display displayRemoveEventHandler ["MouseMoving", _ehMove];
    _display displayRemoveEventHandler ["MouseZChanged", _ehWheel];
};

uiNamespace setVariable [QGVAR(cameraDisplay), nil];
uiNamespace setVariable [QGVAR(cameraHandlers), nil];
uiNamespace setVariable [QGVAR(cameraState), nil];
uiNamespace setVariable [QGVAR(cameraSelPos), nil];
uiNamespace setVariable [QGVAR(camera), nil];

// Terminate and destroy camera
_cam cameraEffect ["Terminate", "Back"];
camDestroy _cam;
player switchCamera "internal";	

GVAR(camera) = nil;
