#define HANDLE_DELAY 0.5
#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_breath_clients

Description:
    Check when should the breath particle be spawned, also handles if it should be spawned if object is either in sight or not.

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_breath_clients;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_SNOWSTORM
    [["% 1: attempted to exec on a client with no interface", __FILE_NAME__], CHAT, "snowstorm"] call EFUNC(tools,debug);
	#endif
};

if(!GVAR(show_breath)) exitWith {
	#ifdef BTC_DEBUG_SNOWSTORM
    [["% 1: client has disabled breath", __FILE_NAME__], CHAT, "snowstorm"] call EFUNC(tools,debug);
	#endif
};
/* private _isKatPresent = isClass (configFile >> "CfgPatches" >> "kat_main");
private _fnc_isBreathingKAT = {
	params[
		["_unit", objNull, [objNull]]
	];
	not((_unit getVariable ["kat_chemical_airPoisoning", false]) || (_unit getVariable ["kat_breathing_tensionpneumothorax", false]) || (_unit getVariable ["kat_breathing_hemopneumothorax", false]))
}; */

private _fnc_getBreathEntitiesData = {
    private _data = [];
    (player nearEntities["CAManBase", 100]) apply {
        private _mouthPos = (ASLToAGL eyePos _x) vectorAdd [0,0,-0.1];
        if(
			//only render if unit is in sight
			worldToScreen _mouthPos isNotEqualTo [] &&
			{[_x] call ace_common_fnc_isAwake}
		) then {
            private _heartRate = _x getVariable ["ace_medical_heartRate", 80]; 
            private _breathsPerMinute = _heartRate / 4;
            private _maxTime = 60 / _breathsPerMinute;  
            _data pushBack [_x, _mouthPos, _maxTime];
        };
    };
    _data
};

//Avoid at any cost duplicates
if(!isNil QGVAR(breath_handle)) then {
    [GVAR(breath_handle)] call CBA_fnc_removePerFrameHandler;
};
GVAR(breath_handle) = [{
    params["_fnc_getBreathEntitiesData", "_handle"];
    ([] call _fnc_getBreathEntitiesData) apply {
		_x params ["_unit", "_mouthPos", "_maxTime"];
		if(underwater _unit) then {
			continue;
		};
		private _deltaTime = HANDLE_DELAY + random[-0.1, 0, 0.1];  
		private _time = _unit getVariable [QGVAR(breath_time), random[0, 0.1, 0.2]]; 
		if(_time >= _maxTime) then {
			_unit setVariable[QGVAR(breath_time), 0];
			private _breath = "#particlesource" createVehicleLocal _mouthPos; 
			_breath setParticleParams [ 
				["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 13, 0], // ShapeName 
				"",       // AnimationName 
				"Billboard",    // Type 
				1,        // TimerPeriod 
				0.25,      // LifeTime 
				[0, 0, 0],   // Position (Relative to attachment) 
				getCameraViewDirection _unit,   // MoveVelocity 
				1, 1.275, 1, 0.05,     // Rotation, Weight, Volume, Rubbing 
				[0.05, 0.15, 0.2],     // Scale 
				[[1, 1, 1, 0.008], [1, 1, 1, 0.002], [1, 1, 1, 0]], // Color (Fades out) 
				[1000],      // AnimSpeed 
				1,        // RandDirPeriod 
				0,        // RandDirIntensity 
				"",       // OnTimerScript 
				"",       // BeforeDestroyScript 
				nil        // Object to attach to 
			]; 
				
			_breath setParticleRandom [2, [0, 0, 0], [0.1, 0.2, 0.1], 0, 0.1, [0, 0, 0, 0], 0, 0]; 
			_breath setDropInterval 0.001; 
						
			// Let it "puff", then stop
			[{
				deleteVehicle _this;
			}, _breath, 0.25] call CBA_fnc_waitAndExecute;
		} else {
			_unit setVariable[QGVAR(breath_time), _time + _deltaTime];
			//systemChat format["_unit: %1 _time %2 to %3, max: %4", _unit, _time, _time + _deltaTime, _maxTime];
		};
    };
}, HANDLE_DELAY, _fnc_getBreathEntitiesData] call CBA_fnc_addPerFrameHandler;
