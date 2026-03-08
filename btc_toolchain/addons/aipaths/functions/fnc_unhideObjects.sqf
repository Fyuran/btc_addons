#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_aipaths_fnc_unhideObjects

Description:
    Unhides textures ingame

Parameters:
    _object -

Returns:

Examples:
    (begin example)
        call btc_toolchain_aipaths_fnc_unhideObjects;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!isServer) exitWith {
    remoteExecCall [QFUNC(unhideObjects), 2];
};
GVAR(objects) = missionNamespace getVariable [QGVAR(objects), []];
if(GVAR(objects) isEqualTo []) exitWith {
    [["%1: no objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _cfg = configFile >> "CfgVehicles";
GVAR(objects) apply {
    private _object = _x;
    private _textures = getArray(_cfg >> typeOf _object >> "hiddenSelectionsTextures");
    {
        _object setObjectTextureGlobal [_forEachIndex, _x];
    } forEach _textures;
};

#ifdef BTC_DEBUG_AIPATHS
[["%1: %1 objects are being shown", __FILE_NAME__, count GVAR(objects)], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
