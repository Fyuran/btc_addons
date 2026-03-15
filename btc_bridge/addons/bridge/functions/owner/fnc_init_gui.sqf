#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_init_gui_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_init_gui_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
disableSerialization;

if(!isNull(findDisplay BRIDGE_DISPLAY)) exitWith {
	[["%1: found a copy of display BRIDGE_DISPLAY already existing", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: Attempted by !hasInterface", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
private _display = createDialog ["btc_bridge_gui", true];
uiNamespace setVariable[QGVAR(display), _display];

_display displayAddEventHandler ["Unload", {
	params ["_display", "_exitCode"];
	#ifdef BTC_DEBUG_BRIDGE
    [["%1: unloading display 667700", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	camDestroy GVAR(camera);
	GVAR(camera) cameraEffect ["terminate", "back"];
	deleteVehicle GVAR(helper);
}];

_display displayAddEventHandler ["MouseMoving", {
    params ["_display", "_xDeltaPos", "_yDeltaPos"];
    GVAR(camera_azimuth) = GVAR(camera_azimuth) - _xDeltaPos;
    GVAR(camera_elevation) = ((GVAR(camera_elevation) - _yDeltaPos) min 45) max 0;
    GVAR(camera_vector) = [
        (cos GVAR(camera_elevation)) * (sin GVAR(camera_azimuth)), 
        (cos GVAR(camera_elevation)) * (cos GVAR(camera_azimuth)), 
        sin GVAR(camera_elevation)
    ] vectorMultiply GVAR(camera_distance);        
    GVAR(camera) camSetRelPos GVAR(camera_vector);
    GVAR(camera) camCommit 0.1;     
}];

_display displayAddEventHandler["MouseZChanged", {
	params ["_displayOrControl", "_scroll"];

	private _vector = GVAR(camera_vector);
	if(_scroll < 0) then {
		_vector = _vector vectorMultiply 1.1;
	} else {
		_vector = _vector vectorMultiply 0.9;        
	};

	private _distance = (((vectorMagnitude _vector) min 40) max 5);        
	if((_distance >= 40) or (_distance <= 5)) exitWith {};

	GVAR(camera_vector) = _vector;
	GVAR(camera_distance) = _distance;
	GVAR(camera) camSetRelPos GVAR(camera_vector);
	GVAR(camera) camCommit 0.1;
}];

_display displayAddEventHandler ["KeyDown", FUNC_O(keyDown)];

_display
