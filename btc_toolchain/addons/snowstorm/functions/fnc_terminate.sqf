#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_snowstorm_fnc_terminate

Description:
    Stops snowfall

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_toolchain_snowstorm_fnc_terminate;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

#ifdef BTC_DEBUG_SNOWSTORM
[["%1: terminating snowstorm on server", __FILE_NAME__], 3, QCOMPONENT] call EFUNC(tools,debug);
#endif
if(!isNil QGVAR(JIP_CSounds)) then { //client sounds handler
    remoteExecCall ["", GVAR(JIP_CSounds)];
};

if(!isNil QGVAR(JIP_Breath)) then {
    remoteExecCall ["", GVAR(JIP_Breath)];
};

if(!isNil QGVAR(JIP_PPE)) then {
    remoteExecCall ["", GVAR(JIP_PPE)];
};

if(!isNil QGVAR(handle)) then { //make sure the previous handler is removed
    [GVAR(handle)] call CBAFUNC(removePerFrameHandler);
};

if(!isNil QGVAR(windTrans)) then { //should wind transition not be done just end it
    terminate GVAR(windTrans); 
};

0 setOvercast 0;
0 setGusts 0;
forceWeatherChange;
TRANS_DELAY setWindStr 0;
TRANS_DELAY setRain 0;
TRANS_DELAY setFog 0;

GVAR(timedSnowstorm) = false;

GVAR(snowfall) = false;
publicVariable QGVAR(snowfall);
//Clients
[] remoteExecCall [QFUNC(terminate_clients), [0, -2] select isDedicated];
