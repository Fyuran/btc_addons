#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_AIPaths_fnc_hideObject

Description:
    Hides object textures ingame and adds it to global pool of hidden objects

Parameters:
    _object -

Returns:

Examples:
    (begin example)
        [cursorObject] call btc_AIPaths_fnc_hideObject;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
    ["_object", objNull, [objNull]]
];
if(!isServer) exitWith {
    _this remoteExecCall [QFUNC(hideObject), 2];
};
#ifdef BTC_DEBUG_AIPATHS
[["%1: %2 is being hidden", __FILE_NAME__, _object], LOGS, "aipaths"] call EFUNC(tools,debug);
#endif

GVAR(objects) = missionNamespace getVariable [QGVAR(objects), []];

private _textures = getObjectTextures _object;
{
    _object setObjectTextureGlobal [_forEachIndex, ""];
    GVAR(objects) pushBack _object;
}forEach _textures;
