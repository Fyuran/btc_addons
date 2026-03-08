#include "\a3\ui_f\hpp\definedikcodes.inc"
#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_init;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[ 
 ["_vehicle", objNull, [objNull]] 
]; 

if(isNull _vehicle) exitWith {
    [["%1: _vehicle is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _display = findDisplay 46;
if(isNull _display) exitWith {
    [["%1: _display is null", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);    
};
if(!isNull GVAR(camera)) exitWith {
    [["%1: attempted to open another bridge UI", __FILE__], REPORT, QCOMPONENT] call EFUNC(tools,debug);     
};

//Global Defines
GVAR(camera_azimuth) = 135;
GVAR(camera_elevation) = 45;
GVAR(camera_distance) = CAMERA_DISTANCE;
GVAR(camera_vector) = [
    (cos GVAR(camera_elevation)) * (sin GVAR(camera_azimuth)), 
    (cos GVAR(camera_elevation)) * (cos GVAR(camera_azimuth)), 
    sin GVAR(camera_elevation)
] vectorMultiply GVAR(camera_distance); 
GVAR(vehicle) = _vehicle;

//Animations
GVAR(animating) = false; //used for the segment transition
GVAR(animating_handle) = -1;

//Initial Camera
GVAR(camera) = "camera" camCreate (getPos _vehicle);
GVAR(camera) camSetTarget (getPos _vehicle);
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) cameraEffect ["internal", "back"]; 
showCinemaBorder false;
GVAR(camera) camCommit 0.1;

GVAR(onUnload_handle) = _display displayAddEventHandler["Unload", {
        _this call FUNC(disable);
}];

GVAR(MouseMoving_handle) = _display displayAddEventHandler ["MouseMoving", {
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

GVAR(keyDown_handle) = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    
    //Undo All
    if(_key isEqualTo DIK_MULTIPLY) exitWith {        
        private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
        _segments apply {
            [] call FUNC(removeLast);
        };
        
        //Camera
        GVAR(camera) camSetTarget (getPos GVAR(vehicle));
        GVAR(camera) camSetRelPos GVAR(camera_vector);
        GVAR(camera) camCommit 0.1;  
    };
    
    //Close UI, adds end segment if there is at least one segment
    if(_key isEqualTo DIK_NUMPADENTER) exitWith {
        private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
        if(_segments isNotEqualTo []) then {
            private _distance = [SEGMENT_DISTANCE + 0.1, CAP_DISTANCE + 0.1] select ((count _segments) <= 1);
            private _segment = ["rhs_pontoon_end_static", _distance] call FUNC(addNext);
        };
        
        [_display] call FUNC(disable);         
     }; 
        
    //Bridge Extension
    //Start/End rhs_pontoon_end_static
    //Segment rhs_pontoon_static
    if(_key isEqualTo DIK_NUMPADPLUS) then {
        private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
        private _segment = objNull;
        if(_segments isEqualTo []) then {            
            _segment = ["rhs_pontoon_end_static", 6.1] call FUNC(addNext);
            //Reverse the ramp to have it point in the right direction
            _segment setVectorDir ((vectorDir _segment) vectorMultiply -1);
            
            //Undo Action only for owner player
            _segment setVariable[QGVAR(segments), GVAR(vehicle) getVariable[QGVAR(segments), []]];
            _segment addAction [
                "<t color='#E63946'>Undo Bridge</t>", 
                {
                    params ["_target", "_caller", "_actionId", "_arguments"];
                    private _segments = _target getVariable[QGVAR(segments), []];
                    _segments apply {deleteVehicle _x};
                }, 
                nil, 
                1.5, 
                false, 
                true, 
                "", 
                "true", 
                5, 
                false, 
                "", 
                ""
            ];
        } else {
            // rhs_pontoon_end_static has a different length 
            private _distance = [SEGMENT_DISTANCE, CAP_DISTANCE] select ((count _segments) <= 1);
            _segment = ["rhs_pontoon_static", _distance] call FUNC(addNext);          
        };       
    };
    
    if(_key isEqualTo DIK_NUMPADMINUS) then {
        private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
        if(_segments isEqualTo []) exitWith {};
        //Camera
        private _previous = [] call FUNC(removeLast);
        if(isNull _previous) then {
            _previous = GVAR(vehicle); 
        };     
    };


}];

GVAR(MouseZChanged_handle) = _display displayAddEventHandler["MouseZChanged", {(_this#1) call FUNC(MouseZChanged)}];
