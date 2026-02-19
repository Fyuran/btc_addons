#include "..\script_component.hpp"
#define RADIUS 30
/* ----------------------------------------------------------------------------
Function: btc_c4booby_fnc_objectInit

Description:
    Passed object is prepared for a bomb defusal situation

Parameters:
    _obj : Object

Returns:

Examples:
    (begin example)
        [this] call btc_c4booby_fnc_objectInit;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
	["_obj", objNull, [objNull]],
	["_end_time", 60, [0]],
	["_max_colors", 1, [0]]
];
if(isNull _obj) exitWith {
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, "c4booby"] call EFUNC(tools,debug);
};

#define __NORTH 0
#define __SOUTH 1
#define __EAST 2
#define __WEST 3

#ifdef BTC_DEBUG_C4BOOBY
[["%1: creating c4 booby %2 at %3", __FILE_NAME__, typeOf _obj, getPosATL _obj], CHAT + LOGS, "c4booby"] call EFUNC(tools,debug);
#endif

private _defuser_VectorDirAndUp = [
	[[0, 1, 0],[0, 0, 1]], //N
	[[0, -1, 0],[0, 0, 1]], //S
	[[1, 0, 0],[0, 0, 1]], //E
	[[-1, 0, 0],[0, 0, 1]] //W
];

//decorations setup
private _deco_pos = call {
	if (_obj isKindOf "CargoNet_01_barrels_F") exitWith { //FUEL
		[ [[0.40,0.40,0.50],[-0.40,0.40,0.50],[-0.40,-0.40,0.50],[0.40,-0.40,0.50]], //explosives positions
			(selectRandom[ [[0,0.65,0.2], __NORTH], [[0,-0.65,0.2], __SOUTH], //defuser random positions
				[[0.65,0,0.2], __EAST], [[-0.65,0,0.2], __WEST] ]),
					[0,0,0.5]] //light
	};

	if (_obj isKindOf "CargoNet_01_box_F") exitWith { //SUPPLIES
		[ [[0.40,0.40,0.58],[-0.40,0.40,0.58],[-0.40,-0.40,0.58],[0.40,-0.40,0.58]], //explosives positions
			(selectRandom[ [[0,0.75,0.2], __NORTH], [[0,-0.75,0.2], __SOUTH], //defuser random positions
				[[0.75,0,0.2], __EAST], [[-0.75,0,0.2], __WEST] ]),
					[0,0,0.6]] //light
	};

	if (_obj isKindOf "CargoNet_01_ammo_base_F") exitWith { //AMMO
		[ [[0.3,0.3,0.8],[-0.30,0.30,0.8],[-0.30,-0.30,0.8],[0.30,-0.30,0.8]], //explosives positions
			(selectRandom[ [[0,0.5,0.6], __NORTH],[[0,-0.5,0.6], __SOUTH], //defuser random positions
				[[0.6,0,0.6], __EAST], [[-0.6,0,0.6], __WEST] ]),
					[0,0,0.9]] //light
	};

	if (_obj isKindOf "Land_MetalBarrel_F") exitWith { //BARREL
		[ [[0.15,0,0.41],[-0.15,0,0.41]], //explosives positions
			(selectRandom[ [[0,0.3,0.2], __NORTH], [[0,-0.3,0.2], __SOUTH], //defuser random positions
				[[0.3,0,0.2], __EAST], [[-0.3,0,0.2], __WEST] ]),
					[0,0,0.52]] //light
	};
	[]
};
if (_deco_pos isEqualTo []) exitWith {
    [["%1: bad _deco_pos: %2", __FILE_NAME__, _deco_pos], REPORT, "c4booby"] call EFUNC(tools,debug);
};

private _exp_pos = _deco_pos select 0;
for "_i" from 0 to (count _exp_pos - 1) do {
	_exp = createSimpleObject ["DemoCharge_F",[0,0,0]];
	_attachPoint = _exp_pos select _i;
	_exp attachTo [_obj,_attachPoint];
	_exp setVectorDirAndUp [[random[-1,0,1], random[-1,0,1], 0],[0, 0, 1]];
};

private _light_pos = _deco_pos select 2;
private _light = "PortableHelipadLight_01_red_F" createVehicle [0,0,0];
_light attachTo [_obj,_light_pos];

//Colors setup
private _wire_colors = [];
for "_i" from 1 to _max_colors do {
	private _x = selectRandom ["red","blue","green"];
	_wire_colors pushBack _x;
};

//defuser setup and actions
private _defuser = "Land_FMRadio_F" createVehicle [0,0,0];
_defuser attachTo [_obj,(_deco_pos select 1) select 0];
private _VecDU_index = ((_deco_pos select 1) select 1);
_defuser setVectorDirAndUp (_defuser_VectorDirAndUp select _VecDU_index);
_defuser setVariable ["wire_colors",_wire_colors,true];
_defuser allowDamage false;
[_defuser,_obj] remoteExecCall[QFUNC(addActions),0,_obj];

//trigger for TIMER and setVariable
private _trigger = createTrigger["EmptyDetector",_obj];
_obj setVariable ["trigger",_trigger];
_trigger attachTo [_obj,[0,0,0]];
_trigger setTriggerArea[RADIUS,RADIUS,0,false];
_trigger setTriggerActivation["ANYPLAYER","PRESENT",false];
_trigger setVariable ["c4booby_trigger_data",[_obj,_max_colors,_end_time]];
_trigger setTriggerStatements ["this", "
	_obj = (thisTrigger getVariable ['c4booby_trigger_data',objNull]) select 0;
	_max_colors = (thisTrigger getVariable ['c4booby_trigger_data',objNull]) select 1;
	_end_time = (thisTrigger getVariable ['c4booby_trigger_data',objNull]) select 2;
	[_obj,_end_time,_max_colors] call btc_c4booby_fnc_timer;
	deleteVehicle thisTrigger;
", ""];

_obj setVariable ["isBoobyTrapped",true,true];
//frame check for SUCCESS or FAIL state
[{
	count ((_this select 1) getVariable ["input_wire_colors",[]]) >= (_this select 2)
},
{
	params["_defuser","_obj","_max_colors","_wire_colors","_light_pos"];
	private _obj_colors = _obj getVariable ["input_wire_colors",[]];
	private _handle = _obj getVariable ["c4booby_timer_handle",0];
	[_handle] call CBA_fnc_removePerFrameHandler;
	[_defuser] remoteExecCall [QFUNC(removeActions),0,_obj];
	(attachedObjects _obj) apply {deleteVehicle _x};
	//Defused
	if (_obj_colors isEqualTo _wire_colors) then {
		private _targets = _obj nearEntities ["CAManBase", 50];
		["ace_medical_feedback_forceSay3D", [_obj, QGVAR(defused), 50], _targets] call CBA_fnc_targetEvent;
		private _light = "PortableHelipadLight_01_green_F" createVehicle [0,0,0];
		_light attachTo[_obj,_light_pos];
		[{deleteVehicle _this}, _light, 60] call CBA_fnc_waitAndExecute;
		_obj setVariable ["isBoobyTrapped",false,true];
	}
	else { //Explode
		private _r = "Bo_GBU12_LGB" createVehicle getPos _obj;
		_r setVectorDirAndUp[[0,0,-1],[1,0,0]]; //steer it towards the ground or odd things will happen
		deleteVehicle _obj;
		hideObjectGlobal _r;
	};

}, [_defuser,_obj,_max_colors,_wire_colors,_light_pos]] call CBA_fnc_waitUntilAndExecute;

_obj
