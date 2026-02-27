#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_drop

Description:
    Commands an air unit to spawn and drop supply items on a location with parachutes.

Parameters:
    _logic[OBJECT]: Module logic containing supply configuration
    _units[ARRAY]: Array of affected units (unused for server-side execution)
    _activated[BOOLEAN]: True when module is activated, false on deactivation

Returns:
    NOTHING

Examples:
    (begin example)
[ 
	plane,  
	[
		"Box_East_WpsSpecial_F", 
		"ACE_medicalSupplyCrate_advanced", 
		"rhs_mags_crate", 
		"Box_NATO_AmmoOrd_F", 
		"rhsusf_m1a1fep_d", 
		"rhsusf_m1025_d_s_m2"
	],  
	[
		[
			["arifle_MX_F", 1], ["30Rnd_65x39_caseless_mag", 4], ["rhsusf_weap_MP7A2", 2], ["rhsusf_mag_40Rnd_46x30_FMJ", 3]
		],
		[],
		[],
		[],
		[
			["arifle_MX_GL_F", 2], ["rhs_mag_M441_HE", 10], ["30Rnd_65x39_caseless_mag", 10]
		],
		[]
	] 
] call btc_supply_fnc_drop;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];

if(!isServer) exitWith {
	[["%1: attempted to call %2 as client", __FILE_NAME__, QFUNC(drop)], REPORT, "supply"] call EFUNC(tools,debug);
};
if(!_activated) exitWith {};
if (isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};
private _logicPos = getPosATL _logic;	
if (surfaceIsWater _logicPos) exitWith {
	[["%1: attempting to supply over water %2", __FILE_NAME__, _logicPos], REPORT, "supply"] call EFUNC(tools,debug);
};

private _vehicleClass = _logic getVariable [QGVAR(vehicleClass), ""];
if(_vehicleClass isEqualTo "") exitWith {
	[["%1: empty vehicle class has been passed to %2", __FILE_NAME__, _logic], REPORT, "supply"] call EFUNC(tools,debug);
};
if(!isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {
	[["%1: bad vehicle class '%2' has been passed to %3", __FILE_NAME__, _vehicleClass, _logic], REPORT, "supply"] call EFUNC(tools,debug);
};

private _data = _logic getVariable [QGVAR(list_value), ""];
if(_data isEqualTo "") exitWith {
	[["%1: bad logic data has been passed to %2", __FILE_NAME__, _logic], REPORT, "supply"] call EFUNC(tools,debug);
};
_data = fromJSON _data;
private _enableDamage = _logic getVariable [QGVAR(enableDamage), true];
#ifdef BTC_DEBUG_SUPPLY
[["%1: calling supply %2 with data: %3", __FILE_NAME__, _logic, [_vehicleClass, _data]], CHAT, "supply"] call EFUNC(tools,debug);
#endif

//Create Pilot and Vehicle
private _randomAngle = random 360;
private _vehPos = _logicPos vectorAdd [(cos _randomAngle) * 2000, (sin _randomAngle) * 2000, 500];
private _veh = createVehicle[_vehicleClass, _vehPos, [], 0, "FLY"];
private _logicPosDirection = _logicPos vectorDiff _vehPos;
_logicPosDirection = [_logicPosDirection#0, _logicPosDirection#1, 0];
_veh setVectorDir _logicPosDirection;
_veh setVelocityModelSpace [0, 30, 10]; //accelerate
_veh allowDamage _enableDamage;

private _grp = createGroup [civilian, true];
_grp setVariable["acex_headless_blacklist", true];
private _pilot = _grp createUnit ["C_man_pilot_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_pilot assignAsDriver _veh;
_pilot moveInDriver _veh;

allCurators apply {
	_x addCuratorEditableObjects [[_veh], true];
};

//Assign waypoints
private _wp1 = _grp addWaypoint [[_logicPos#0, _logicPos#1, 500], 0];
_wp1 setWaypointBehaviour "CARELESS";
private _wp2 = _grp addWaypoint [_logicPos vectorAdd [(_logicPosDirection#0) * 10, (_logicPosDirection#1) * 10, 500], 0];
_wp2 setWaypointBehaviour "CARELESS";

private _paradropData = [];
/*
    HashMap structure is as follows:
	    "vehicle": STRING
        "allowDamage": BOOL
        "CLASS-diag_tickTime-hashedChars": HashMap
            "class": STRING
            "inventory": HashMap
                "CFG_CLASS_1": SCALAR
                "CFG_CLASS_2": SCALAR
                ...
*/
_data apply {
	private _paradropClass = _y get "class";
	private _paradropInventory = (_y get "inventory") apply {
		[_x, _y] params [
			["_class", "", [""]],
			["_amount", 1, [123]]
		];
		[_class, _amount];
	};
	_paradropData pushBack [_paradropClass, _paradropInventory];
};

#ifdef BTC_DEBUG_SUPPLY
[["%1: parsed data is: %2", __FILE_NAME__, _paradropData], CHAT, "supply"] call EFUNC(tools,debug);
#endif

deleteVehicle _logic;
[_logicPos, _veh, _paradropData] spawn {
	params[
		["_logicPos", [0, 0, 0], [[]]],
		["_veh", objNull, [objNull]],
		["_paradropData", [], []]
	];
	if(_logicPos isEqualTo [0, 0, 0]) exitWith {
		[["%1: _logicPos is invalid pos: %2", __FILE_NAME__, _logicPos], REPORT, "supply"] call EFUNC(tools,debug);
	};
	if (isNull _veh) exitWith {
		[["%1: _veh is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
	};
	if(_paradropData isEqualTo []) exitWith {
		[["%1: empty _paradropClasses", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
	};
	private _time = CBA_missionTime + 300; //5 minutes
	waitUntil{(_veh distance2D _logicPos) <= 100 || CBA_missionTime >= _time};
	_paradropData apply {
		_x params [
			["_paradropClass", "", [""]],
			["_inventory", [], [[]]]
		];
		 //if object is a class create a vehicle else null check
		if(!isClass (configFile >> "CfgVehicles" >> _paradropClass)) then {
			[["%1: invalid class %2", __FILE_NAME__, _paradropClass], REPORT, "supply"] call EFUNC(tools,debug);
		   continue; 
		};
		if(!alive _veh) exitWith {
			#ifdef BTC_DEBUG_SUPPLY
			[["%1: veh is not alive or has become null", __FILE_NAME__], 3, "supply"] call EFUNC(tools,debug);
			#endif
		};
		private _vehPosATL = getPosATL _veh;
		
		if((_vehPosATL#2) < 15) then {
			#ifdef BTC_DEBUG_SUPPLY
			[["%1: flight path too low, must be above 15m, currently: %2", __FILE_NAME__, _vehPosATL#2], REPORT, "supply"] call EFUNC(tools,debug);
			#endif
			continue;
		};
		
		private _calculatedDropPos = _vehPosATL vectorAdd ((vectorDir _veh) vectorMultiply -15);

		_calculatedDropPos = _calculatedDropPos vectorDiff [0, 0, 1];
		private _supply = createVehicle[_paradropClass, [0, 0, 100], [], 0, "CAN_COLLIDE"];  
		_supply setPosATL _calculatedDropPos;
		_supply setVectorDir(vectorDir _veh);

		//parachute must not be spawned as "FLY" as it will spawn 150 m above ground
		private _para = createVehicle ["I_Parachute_02_F", (getPosATL _supply) vectorAdd [0, 0, 1], [], 0, "CAN_COLLIDE"];
		_para setVehicleLock "LOCKED"; //prevent stupid shit from happening
		_supply attachTo [_para, [0,0,0]];
		_para setVectorDir(vectorDir _veh);
		_para setVelocityModelSpace [0, 10, 0];
		
		//ground landing smoke and detach from parachute to avoid ground clipping						
		[
		{
			(getPos(_this#0)#2) <= 1 || CBA_missionTime >= (_this#1)
		},
		{
			params[
				["_supply", objNull, [objNull]]
			];
			detach _supply;
			private _posATL = getPosATL _supply;
			private _smoke = "SmokeShellGreen" createVehicle _posATL;
			_smoke attachTo [_supply, [0,0,0]]; 
		},
		[_supply, CBA_missionTime + 30]
		] call CBA_fnc_waitUntilAndExecute;

		sleep 0.5;	

		//inventory parsing
		if(_inventory isEqualTo []) then {
			continue;
		};
		clearMagazineCargoGlobal _supply;
		clearWeaponCargoGlobal _supply;
		clearBackpackCargoGlobal _supply;
		clearItemCargoGlobal _supply; //also removes vests and uniforms
		
		private _backpackBase = configFile >> "CfgVehicles" >> "Bag_Base";
		_inventory apply {
			_x params[
				["_class", "", [""]],
				["_count", 1, [123]]
			];
			if(
				(!isClass (configFile >> "CfgVehicles" >> _class)) &&
				{(!isClass (configFile >> "CfgWeapons" >> _class))} && 
				{(!isClass (configFile >> "CfgAmmo" >> _class))} &&
				{(!isClass (configFile >> "CfgMagazines" >> _class))}
			) then {
				[["%1: invalid class %2", __FILE_NAME__, _class], REPORT, "supply"] call EFUNC(tools,debug);
				continue;
			};
			
			if !([_supply, _class] call CBA_fnc_canAddItem) then {
				[["%1: no inventory room for %2 in %3", __FILE_NAME__, _class, _paradropClass], REPORT, "supply"] call EFUNC(tools,debug);
				continue;
			};
			
			private _probableBackpack = configFile >> "CfgVehicles" >> _class;
			private _inheritsFromBackpackbase = [_probableBackpack, _backpackBase] call CBA_fnc_inheritsFrom;
			if(_inheritsFromBackpackbase) then {
			_supply addBackpackCargoGlobal[_class, (_count) max 1];												 
			} else {
			_supply addItemCargoGlobal[_class, (_count) max 1]; //Works with items, weapons, magazines, equipment and glasses but not backpacks.
			};			 
		};		 
	};

	[
	{
		CBA_missionTime >= (_this#1)
	},
	{
		params[
			["_veh", objNull, [objNull]]
		];

		deleteVehicle driver _veh;
		deleteVehicle _veh;
		#ifdef BTC_DEBUG_SUPPLY
		[["%1: Supply drop complete, deleting _veh %2", __FILE_NAME__, _veh], 3, "supply"] call EFUNC(tools,debug);
		#endif
	},
	[_veh, CBA_missionTime + 60]
	] call CBA_fnc_waitUntilAndExecute;
};
#ifdef BTC_DEBUG_SUPPLY
[["%1: %2 Spawning supplies...", __FILE_NAME__, _vehicleClass], 3, "supply"] call EFUNC(tools,debug);
#endif
