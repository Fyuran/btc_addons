#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_AIPaths_fnc_hideObjects

Description:
    Hides textures ingame

Parameters:
    _object -

Returns:

Examples:
    (begin example)
        call btc_AIPaths_fnc_hideObjects;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!isServer) exitWith {
    remoteExecCall [QFUNC(hideObjects), 2];
};
GVAR(objects) = missionNamespace getVariable [QGVAR(objects), []];
if(GVAR(objects) isEqualTo []) exitWith {
    [["%1: no btc_AIPaths objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

GVAR(objects) apply {
    private _object = _x;
    private _textures = getObjectTextures _object;
    {
        _object setObjectTextureGlobal [_forEachIndex, ""];
    } forEach _textures;
};

#ifdef BTC_DEBUG_AIPATHS
[["%1: %1 objects are being hidden", __FILE_NAME__, count GVAR(objects)], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
