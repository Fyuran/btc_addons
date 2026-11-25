#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_cleanUp

Description:
    Destroys the insignia inspection camera and removes attached event handlers.

Parameters:

Returns:
    NOTHING

Examples:
    (begin example)
        [] call btc_toolchain_insignia_fnc_cleanUp;
    (end)

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */

// Remove display event handlers
private _display = uiNamespace getVariable [QGVAR(cameraDisplay), displayNull];
private _handlers = uiNamespace getVariable [QGVAR(cameraHandlers), []];
if (!isNull _display && { _handlers isNotEqualTo [] }) then {
    _handlers params [
        ["_keyDown", -1, [123]],
        ["_ehDown", -1, [123]],
        ["_ehUp", -1, [123]],
        ["_ehMove", -1, [123]],
        ["_ehWheel", -1, [123]]
    ];

    _display displayRemoveEventHandler ["KeyDown", _keyDown];
    _display displayRemoveEventHandler ["MouseButtonDown", _ehDown];
    _display displayRemoveEventHandler ["MouseButtonUp", _ehUp];
    _display displayRemoveEventHandler ["MouseMoving", _ehMove];
    _display displayRemoveEventHandler ["MouseZChanged", _ehWheel];
};

uiNamespace setVariable [QGVAR(cameraDisplay), nil];
uiNamespace setVariable [QGVAR(cameraHandlers), nil];
uiNamespace setVariable [QGVAR(cameraState), nil];
uiNamespace setVariable [QGVAR(cameraSelPos), nil];
uiNamespace setVariable [QGVAR(nvg), nil];

// Terminate and destroy camera
private _cam = uiNamespace getVariable [QGVAR(camera), objNull];
if (!isNull _cam) then {
    camUseNVG false;
    _cam cameraEffect ["Terminate", "Back"];
    camDestroy _cam;
    player switchCamera "internal";
};
uiNamespace setVariable [QGVAR(camera), nil];
