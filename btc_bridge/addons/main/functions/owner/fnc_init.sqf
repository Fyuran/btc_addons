#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_fnc_init_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_fnc_init_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[ 
	["_vehicle", objNull, [objNull]] 
]; 

if(isNull _vehicle) exitWith {
    [["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!local _vehicle) exitWith {
    [["%1: _vehicle is not local", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
if(!isNull(findDisplay BRIDGE_DISPLAY)) exitWith {
	[["%1: found a copy of display BRIDGE_DISPLAY already existing", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
};
//"B_Truck_01_flatbed_F"
if(!isClass (configOf _vehicle)) exitWith {
    [["%1: Bridge layer has incorrect class, should be ""B_Truck_01_flatbed_F""", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);     
};
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

//Camera
GVAR(camera_azimuth) = 135;
GVAR(camera_elevation) = 45;
GVAR(camera_distance) = CAMERA_DISTANCE;
GVAR(camera_vector) = [
    (cos GVAR(camera_elevation)) * (sin GVAR(camera_azimuth)), 
    (cos GVAR(camera_elevation)) * (cos GVAR(camera_azimuth)), 
    sin GVAR(camera_elevation)
] vectorMultiply GVAR(camera_distance); 

GVAR(camera) = "camera" camCreate (getPosASL _vehicle);
GVAR(camera) camSetTarget (getPosASL _vehicle);
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) cameraEffect ["internal", "back"]; 
showCinemaBorder false;
GVAR(camera) camCommit 0.1;

//Helper arrow that will show where next segment center will be
GVAR(helper) = createVehicleLocal["Sign_Arrow_Large_Blue_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
private _forward = (vectorNormalized(vectorDir _vehicle)) vectorMultiply -1;
private _vehicle_posASL = getPosASL _vehicle;
private _front_start_posASL = _vehicle_posASL vectorAdd (_forward vectorMultiply FRONT_OFFSET_MULTIPLIER);
GVAR(helper) setPosASL _front_start_posASL;
[{
	if(!isNull GVAR(camera)) then {
		private _currentDir = getDir GVAR(helper);
    	GVAR(helper) setDir ((_currentDir + (200 * diag_deltaTime)) % 360);
	} else {
		deleteVehicle GVAR(helper);
		[_this#1] call CBA_fnc_removePerFrameHandler;
	};
}] call CBA_fnc_addPerFrameHandler;

//Global defines
GVAR(vehicle) = _vehicle;
_vehicle setVariable[QGVAR(JIPUID), [] call BTCFUNC(tools,uid)];
[] call FUNC_O(init_gui);
