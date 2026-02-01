#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_snowSounds_clients

Description:
    Handles sound for player

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_snowSounds_clients;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!hasInterface) exitWith {};
if(!isNil QGVAR(indoor_handle)) then {
    stopSound(GVAR(windSoundID));
    [GVAR(indoor_handle)] call CBA_fnc_removePerFrameHandler;
    [GVAR(sound_loop_handle)] call CBA_fnc_removePerFrameHandler;
};

GVAR(windSoundID) = -1;
GVAR(indoor_handle) = -1;
GVAR(sound_loop_handle) = -1;
GVAR(isIndoors) = true;
GVAR(windSounds) = [
    QGVAR(h_windLoop),
    QGVAR(h_windLoop_2)
];
GVAR(indoor_windSounds) = [
    QGVAR(indoor_h_windLoop),
    QGVAR(indoor_h_windLoop_2)
];

enableEnvironment false;

//periodic checking of player position
GVAR(indoor_handle) = [{
    private _pos1 = getPosWorldVisual player;
    private _pos2 = _pos1 vectorAdd [0, 0, 10];
    private _objects = lineIntersectsWith[_pos1, _pos2, player, objNull, true];
    private _isHouse = if((count _objects) > 0) then {
        (_objects#0) isKindOf "House"
    } else {
        false
    };

    if (!GVAR(isIndoors) && {_isHouse}) then { //indoor sound (it's a muffled version of the original one playing)
        [GVAR(sound_loop_handle)] call CBA_fnc_removePerFrameHandler;
        stopSound(GVAR(windSoundID));
        GVAR(isIndoors) = true;

        playSoundUI [QGVAR(wind_transition), 1, 1, true, 0];
        GVAR(sound_loop_handle) = [{
            GVAR(windSoundID) = playSoundUI [selectRandom GVAR(indoor_windSounds), 1, 1, true, 0];
        }, 59, []] call CBA_fnc_addPerFrameHandler;

    } else {
        if(GVAR(isIndoors) && {!_isHouse}) then { //outdoor sound
            [GVAR(sound_loop_handle)] call CBA_fnc_removePerFrameHandler;
            stopSound(GVAR(windSoundID));
            GVAR(isIndoors) = false;

            playSoundUI [QGVAR(wind_transition), 1, 1, true, 0];
            GVAR(sound_loop_handle) = [{
                GVAR(windSoundID) = playSoundUI [selectRandom GVAR(windSounds), 1, 1, true, 0];
            }, 59, []] call CBA_fnc_addPerFrameHandler;
        };
    };
}, 0.1, []] call CBA_fnc_addPerFrameHandler;
