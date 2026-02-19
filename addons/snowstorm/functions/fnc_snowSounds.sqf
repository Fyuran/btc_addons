#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_snowSounds

Description:
    Handles sounds on client

Parameters:
    _intensity: Based on wind strength have different options
Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_snowSounds;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
    ["_intensity", 0, [123]]
];
if(_intensity <= 0) exitWith {
    [["% 1: _intesity is zero or below", __FILE_NAME__], REPORT, "snowstorm"] call EFUNC(tools,debug);
};
if(random 1 < 0.98) exitWith {
    #ifdef BTC_DEBUG_SNOWSTORM
    [["% 1: chance was not high enough", __FILE_NAME__], CHAT, "snowstorm"] call EFUNC(tools,debug);
	#endif
};

GVAR(ambientSound) = -1;
private _allPlayers = ([] call BIS_fnc_listPlayers) select {alive _x};

if(_allPlayers isNotEqualTo []) then {
    private _randomPlayer = selectRandom _allPlayers;
    private _randomPosASL = [getPosASL _randomPlayer, 1] call CBA_fnc_randPos;
    GVAR(ambientSound) = playSound3D[selectRandom[QPATHTOF(sounds\Wolf1.ogg), QPATHTOF(sounds\Wolf2.ogg)], objNull, false, _randomPosASL, 1, 1, 0, 0, false];
};
