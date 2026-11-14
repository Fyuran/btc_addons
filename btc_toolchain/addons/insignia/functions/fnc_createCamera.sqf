#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_createCamera

Description:
    Creates an inspection camera focused on a unit's insignia selection.
    Allows orbiting around the focus position by holding the right mouse button and dragging,
    with mouse wheel zoom support.

Parameters:
    _selection: STRING or ARRAY - Character model selection names (defaults to "leftarm")
    _distance: NUMBER (defaults to 1)
    _display: DISPLAY

Returns:
    OBJECT

Examples:
    (begin example)
        private _cam = [] call btc_toolchain_insignia_fnc_createCamera;
    (end)
    (begin example)
        // With custom UI display and distance:
        private _cam = ["leftarm", _myDisplay, 0.6] call btc_toolchain_insignia_fnc_createCamera;
    (end)

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */

params [
    ["_selectionPos", "leftarm", ["", []]],
    ["_distance", 1, [123]],
    ["_parentDisplay", findDisplay 46, [displayNull]]
];

if (!alive player) exitWith { 
    #ifdef BTC_DEBUG_INSIGNIA
	[["%1: player is not alive", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    objNull
};

if (isNull _parentDisplay) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
	[["%1: _parentDisplay is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    objNull
};

// Retrieve model-space position from model named selection
private _selectionPos = if (_selectionPos isEqualType "") then {
    player selectionPosition _selectionPos
} else {
    _selectionPos
};

// Terminate previous camera if still active
private _prevCam = uiNamespace getVariable [QGVAR(camera), objNull];
if (!isNull _prevCam) then {
    [_prevCam] call FUNC(destroyCamera);
};

// Initial heading: facing the outside of the player's left arm in world space
private _initialAzimuth = player getDir _selectionPos;
private _dist2D = vectorMagnitude [_selectionPos#0, _selectionPos#1, 0];
private _initialElevation = (_selectionPos#2) atan2 _dist2D;

// State array: [_isHoldingRMB, _azimuth, _elevation, _distance]
private _state = [false, _initialAzimuth, _initialElevation, _distance];

// Create camera object
private _camVector = [
    (cos _initialElevation) * (sin _initialAzimuth), 
    (cos _initialElevation) * (cos _initialAzimuth), 
    sin _initialElevation
] vectorMultiply _distance;

private _cam = "camera" camCreate (getPos player);
_cam cameraEffect ["Internal", "Back"];
_cam camSetTarget (player modelToWorldVisual _selectionPos);
_cam camSetRelPos _camVector;
_cam camCommit 0.1;
showCinemaBorder false;
cameraEffectEnableHUD true;

// Store variables in uiNamespace
uiNamespace setVariable [QGVAR(camera), _cam];
uiNamespace setVariable [QGVAR(cameraSelPos), _selectionPos];
uiNamespace setVariable [QGVAR(cameraState), _state];
uiNamespace setVariable [QGVAR(cameraDisplay), _parentDisplay];

private _ehDown = _parentDisplay displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];
    [_button, true] call FUNC(mouseButton);
}];

private _ehUp = _parentDisplay displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button"];
    [_button, false] call FUNC(mouseButton);
}];

private _ehMove = _parentDisplay displayAddEventHandler ["MouseMoving", {
    params ["", "_xDelta", "_yDelta"];
    [_xDelta, _yDelta] call FUNC(mouseMoving);
}];

private _ehWheel = _parentDisplay displayAddEventHandler ["MouseZChanged", {
    params ["", "_zChange"];
    [_zChange] call FUNC(mouseZChanged);
}];

// Store EHs for later deletion
uiNamespace setVariable [QGVAR(cameraHandlers), [_ehDown, _ehUp, _ehMove, _ehWheel]];

// Apply initial positioning
[] call FUNC(update);

_cam
