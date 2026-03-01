#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_snowstorm_fnc_snowDust_clients

Description:
    Spawns several particles simulating wind lifting snow

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_toolchain_snowstorm_fnc_snowDust_clients;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_SNOWSTORM
    [["%1: attempted to exec on a client with no interface", __FILE_NAME__], CHAT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};

if(!isNil QGVAR(snowDust)) then { //do not allow more than one particle object
	deleteVehicle GVAR(snowDust);
};

private _curRain = rain;

// Adjust drop interval based on rain strength
private _dropInterval = linearConversion[0, 1, rain, 0.008, 0.09, true];
private _radius = [15, 40] select (!isNull objectParent player);

private _snowDust = "#particlesource" createVehicleLocal ([player, 50] call CBAFUNC(randPos));
GVAR(snowDust) = _snowDust;

private _emissive = [[4,4,4,0]];
private _opacityFactor = 1;
if (((apertureParams select 0) < 9) && {currentVisionMode player == 0}) then {
	// Night
	_opacityFactor = 0.2 + (fog / 2);
	_emissive = [[0.5, 0.5, 0.5, 0]];
} else {
	// Day
	_opacityFactor = 0.2;
	_emissive = [[100, 100, 100, 0]];
};

_snowDust setParticleCircle [_radius, wind];

_snowDust setParticleRandom [
	0, //lt
	[15, 15, 0], //pos
	[0, 0, 0], //vel
	3, // rotvel
	0.1, // size
	[0,0,0,0], //col
	0,
	0
];

_snowDust setParticleParams [
	["\A3\data_f\cl_basic", 1, 0, 1], //["A3\Data_F\ParticleEffects\Universal\Universal", 16, 12, 8, 1],
	"",
	"Billboard",
	1, // timer per
	10, // lt
	[0, 0, 0], //pos
	[1, 0, -0.1], // vel
	3, // rot vel
	0.3, // weight
	0.232, //vol
	0.02, //rub
	[2, 10, 15], //size
	[[1,1,1, 0.001],[1,1,1, 0.01],[1,1,1, _opacityFactor], [1, 1, 1, _opacityFactor],[1, 1, 1, _opacityFactor/2],[1,1,1, 0.05],[1,1,1, 0.01],[1,1,1, 0]], //col
	[3], // anim speed
	1, // rand dir per
	0, // rnd dir intens
	"", // on timer script
	"", // before destroy script
	player, // obj
	0,  // angle
	true, // on surface
	-1, // bounceOnSurface
	_emissive // emissive col for daylight effect
];

_snowDust setDropInterval _dropInterval;
