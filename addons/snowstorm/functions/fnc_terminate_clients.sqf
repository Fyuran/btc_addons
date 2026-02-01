#define SOUNDS 2
#define BREATH 4
#define SNOWDUST 6
#define PPE 8
#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_terminate_clients

Description:
    Stops snowfall on client side

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_terminate_clients;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
    ["_flag", 14, [123]]
];

private _disableSounds = [_flag, SOUNDS] call BIS_fnc_bitflagsCheck;
private _disableBreath = [_flag, BREATH] call BIS_fnc_bitflagsCheck;
private _disableSnowDust = [_flag, SNOWDUST] call BIS_fnc_bitflagsCheck;
private _disablePPE = [_flag, PPE] call BIS_fnc_bitflagsCheck;

if(_disableSounds) then {
    if(GVAR(windSoundID) != -1) then {
        stopSound GVAR(windSoundID);
        GVAR(windSoundID) = -1;
    };

    if(!isNil QGVAR(sound_loop_handle)) then { //sound loop
        [GVAR(sound_loop_handle)] call CBA_fnc_removePerFrameHandler;
        GVAR(sound_loop_handle) = nil;
    };

    if(!isNil QGVAR(indoor_handle)) then {
        [GVAR(indoor_handle)] call CBA_fnc_removePerFrameHandler;
        GVAR(indoor_handle) = nil; //reset to allow execution of client side function again
    };

    enableEnvironment true;
};

if(_disableBreath) then {
    [GVAR(breath_handle)] call CBA_fnc_removePerFrameHandler;
    GVAR(breath_handle) = nil;
};

if(_disableSnowDust) then {
    if(!isNil QGVAR(snowDust)) then {
        deleteVehicle GVAR(snowDust);
    };
};

if(_disablePPE) then {
    if(!isNil QGVAR(color_correction)) then {
        ppEffectDestroy GVAR(color_correction);
    };
};
