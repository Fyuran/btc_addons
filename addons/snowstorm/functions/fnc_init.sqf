#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_snowstorm_fnc_init

Description:
    Initiates snowfall.

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_toolchain_snowstorm_fnc_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

if(!isServer) exitWith {};

params[
	["_fogValue", 0.5, [123]],
	["_fogDecay", 0, [123]],
	["_fogBase", 0, [123]],
	["_duration", -1, [123]], //passed duration should be seconds
	["_windIntensity", [20, 30, 40], [[]], 3]
];
GVAR(duration) = -1;
GVAR(timedSnowstorm) = false;
GVAR(snowfall) = true;
publicVariable QGVAR(snowfall);
if(_duration > 0) then { 
	GVAR(duration) = CBA_missionTime + (GVAR(duration) * 1000); //s to ms
	GVAR(timedSnowstorm) = true;
};

if(!isNil QGVAR(handle)) then { //make sure the previous handler is removed
	[] remoteExecCall [QFUNC(terminate), 0];
};

//ace will overwrite any kind of weather settings passed
if(ACEGVAR(weather,windSimulation)) exitWith {
	[["%1: snowfall could not be executed while ace is managing wind simulation", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

0 setRainbow 0;
0 setGusts 1;
0 setOvercast 1;
[
	"a3\data_f\snowflake4_ca.paa", 
	4, 
	0.01, 
	60, 
	1, 
	40, 
	0.5, 
	0.5, 
	0.07, 
	0.07, 
	[1, 1, 1, 0.5], 
	0.5, 
	0.5, 
	0.5, 
	0.5, 
	true, 
	false 
] call BIS_fnc_setRain;
forceWeatherChange;

TRANS_DELAY setFog [_fogValue, _fogDecay, _fogBase];
TRANS_DELAY setRain 1;
GVAR(windTrans) = [TRANS_DELAY, 40] spawn FUNC(windSmoothTrans);
[
{
	[] remoteExecCall [QFUNC(snowDust_clients), [0, -2] select isDedicated];
	GVAR(handle) = [{
		0 setOvercast 1;
		private _randMag = random [10, 15, 20];
		[
			"a3\data_f\snowflake4_ca.paa", // texture of the particle (r = alpha; g = normalX; b = normalY; a = color;)
			4, // dropsInTexture - the number of drops that are present in the drop texture
			0.01, // minimum rain strength when the effect starts to be rendered
			_randMag, // distance of the effect
			0.8, // coefficient of how much the wind influences water drops
			_randMag, // fall speed of the drops
			0.5, // random part of the fall speed
			0.5, // coefficient of how much the drop could randomly change direction
			0.07, // width of the single drop
			0.07, // height of the single drop
			[1, 1, 1, 0.45], // color of the drop
			0.5, // luminescence of the drop facing to sun	
			0.5, // luminescence of the drop opposite to sun
			0.5, // coefficient that tells us how much "refracted" light from the scene is added to the drop color
			0.5, // coefficient to tune color saturation of the refraction effect (0=BW, 1=original color)
			true, // rain is snow, will be used in "snow" env sound controller (optional, default is false)
			false // when true, the dropColor is preserved and not affected by eye accommodation (optional, default is false)
		] call BIS_fnc_setRain;
		[_randMag] call FUNC(snowSounds);
		0 setRain 1;

		GVAR(windTrans) = [TRANS_DELAY, random (_this#0)] spawn FUNC(windSmoothTrans);

		if(GVAR(timedSnowstorm)) then {
			GVAR(duration) = GVAR(duration) - CBA_missionTime;
			if(GVAR(duration) <= 0) then {
				[] remoteExecCall [QFUNC(terminate), 0];
			};
		};
	}, TRANS_DELAY, _this] call CBAFUNC(addPerFrameHandler);
}, _windIntensity, TRANS_DELAY] call CBAFUNC(waitAndExecute);

//Clients
GVAR(JIP_CSounds) = [] remoteExecCall [QFUNC(snowSounds_clients), [0, -2] select isDedicated, true]; //jip id removal is handled in terminate fnc
GVAR(JIP_Breath) = [] remoteExecCall [QFUNC(breath_clients), [0, -2] select isDedicated, true]; //jip id removal is handled in terminate fnc
GVAR(JIP_PPE) = [] remoteExecCall [QFUNC(postprocess_clients), [0, -2] select isDedicated, true]; //jip id removal is handled in terminate fnc
