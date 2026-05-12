#include "..\script_component.hpp"
#define _OPFOR_ 0
#define _BLUFOR_ 1
#define _INDEPENDENT_ 2
#define _CIVILIAN_ 3

private _fnc_removeEh = {
	params[
		["_unit", objNull, [objNull]]
	];

	if(!alive _unit) exitWith {};
	_EHs = _unit getVariable[QGVAR(client_EHs), []];

	_EHs params [
		["_suppressedEH", -1, [123]],
		["_killedEH", -1, [123]],
		["_hitEH", -1, [123]],
		["_fireEH", -1, [123]]
	];
	_unit removeEventHandler["Suppressed", _suppressedEH];
	_unit removeEventHandler["Killed", _killedEH];
	_unit removeEventHandler["Hit", _hitEH];
	_unit removeEventHandler["FiredMan", _fireEH];

};

(missionNamespace getVariable[QGVAR(groups), []]) apply {
	private _units = units _x;
	_units apply {
		private _unit = _x;
		private _suppressedEH = _unit addEventHandler ["Suppressed", { 
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
			[getPos _ammoObject] spawn {
				_time = CBA_missionTime + 5;
				waitUntil {
					drawIcon3D ["", [1,0,0,1], _this#0, pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "SUPPRESSED"];
					CBA_missionTime > _time;
				};
			};
		}];
		private _killedEH = _unit addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[_unit] spawn {
				_time = CBA_missionTime + 5;
				waitUntil {
					drawIcon3D ["", [1,0,0,1], (_this#0) modelToWorldVisual [0,0,0.5], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "KILLED"];
					CBA_missionTime > _time;
				};
			};
			[QGVAR(debug_removeEHs), [_unit]] call CBA_fnc_localEvent;
		}];

		private _hitEH = _unit addEventHandler ["Hit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			[_unit] spawn {
				_time = CBA_missionTime + 5;
				waitUntil {
					drawIcon3D ["", [1,0,0,1], (_this#0) modelToWorldVisual [0,0,0.5], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "HIT"];
					CBA_missionTime > _time;
				};
			};
		}];

		private _fireEH = _unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			[_unit, random[0.5, 1, 1.7], random[0,0.5,1]] spawn {
				_time = CBA_missionTime + 1;
				waitUntil {
					drawIcon3D ["", [_this#2, 0, 0, 1], (_this#0) modelToWorldVisual [0, 0, _this#1], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "FIRED"];
					CBA_missionTime > _time;
				};
			};
		}];

		_unit setVariable[QGVAR(client_EHs), [_suppressedEH, _killedEH, _hitEH, _fireEH]];
	};
};

//Check if handles already exist
private _handle = missionNamespace getVariable [QGVAR(removeEH_clients_handle), -1];
if(_handle isNotEqualTo -1) exitWith {};
removeEH_clients_handle = [QGVAR(debug_removeEHs), _fnc_removeEh] call CBA_fnc_addEventHandler;

_handle = missionNamespace getVariable [QGVAR(debug_PFH_handle), -1];
if(_handle isNotEqualTo -1) exitWith {};

debug_PFH_handle = [{
private _groups = missionNamespace getVariable[QGVAR(groups), []];
if(_groups isEqualTo []) exitWith {};
_groups apply {
	private _group = _x;
	private _isGroupAlive = false;
	if(isNull _group) then {continue};
	(units _group) apply {
		if(alive _x) then {
			_isGroupAlive = true;
			break;
		};
	};
	if(!_isGroupAlive) then {continue};

	private _side = side _group;
	private _group_icon = switch([_side] call BIS_fnc_sideID) do {
		case _OPFOR_: {"\a3\ui_f\data\map\markers\nato\o_inf.paa"};
		case _BLUFOR_: {"\a3\ui_f\data\map\markers\nato\b_inf.paa"};
		case _INDEPENDENT_: {"\a3\ui_f\data\map\markers\nato\n_inf.paa"};
		default {"\a3\ui_f\data\map\markers\nato\c_unknown.paa"};
	};
	private _enemyColor = switch([_side] call BIS_fnc_sideID) do {
		case _OPFOR_ : {[
			profileNamespace getVariable ['Map_OPFOR_R',0], 
			profileNamespace getVariable ['Map_OPFOR_G',1], 
			profileNamespace getVariable ['Map_OPFOR_B',1], 
			profileNamespace getVariable ['Map_OPFOR_A',0.8]
		]};
		case _BLUFOR_ : {[
			profileNamespace getVariable ['Map_BLUFOR_R',0], 
			profileNamespace getVariable ['Map_BLUFOR_G',1], 
			profileNamespace getVariable ['Map_BLUFOR_B',1], 
			profileNamespace getVariable ['Map_BLUFOR_A',0.8]
		]};
		case _INDEPENDENT_ : {[
			profileNamespace getVariable ['Map_Independent_R',0], 
			profileNamespace getVariable ['Map_Independent_G',1], 
			profileNamespace getVariable ['Map_Independent_B',1], 
			profileNamespace getVariable ['Map_Independent_A',0.8]
		]};
		default {[
			profileNamespace getVariable ['Map_Civilian_R',0], 
			profileNamespace getVariable ['Map_Civilian_G',1], 
			profileNamespace getVariable ['Map_Civilian_B',1], 
			profileNamespace getVariable ['Map_Civilian_A',0.8]
		]};
	};

	private _threat = _group getVariable[QGVAR(threat), 0];
	private _body_threat = _group getVariable[QGVAR(body_threat), 0];

	private _positions = [];
	(units _group) apply { 
		if(alive _x) then {
			_positions pushBack (getPosVisual _x)
		};
	};
	private _centroid = [0, 0, 0];
	if(_positions isNotEqualTo []) then {
		_centroid = ([_positions, true] call FUNC(getCentroid)) vectorAdd [0, 0, 4];

		drawIcon3D [_group_icon, _enemyColor, _centroid, pixelW * pixelGrid * 100, pixelH * pixelGrid * 80, 0];
		private _currentState = [_group, _group getVariable[QGVAR(FSM), locationNull]] call CBA_statemachine_fnc_getCurrentState;
		drawIcon3D ["", [1,0,0,1], _centroid vectorAdd[0,0,0.4], 1, 1, 0, format["FSM:%1", _currentState]];
		drawIcon3D ["", [0,1,1,1], _centroid vectorAdd[0,0,0.6], 1, 1, 0, format["%1:%2", ["THREAT", "BODY_THREAT"] select (_body_threat > _threat), _threat max _body_threat]];
	};

	private _lastKnownPos = _group getVariable[QGVAR(lastKnownPos), [0, 0, 0]];
	if (_lastKnownPos isNotEqualTo [0, 0, 0]) then {
		drawIcon3D ["", [1,0,0,1], _lastKnownPos, 1, 1, 0, "!"];
	};

	(units _group) apply {
		private _unit = _x;
		if(!alive _unit) then {continue};
		if(_unit getVariable ["ACE_isUnconscious", false]) then {continue};

		private _unitPos = getPosVisual _unit;

		
		//drawIcon3D ["\a3\ui_f\data\map\vehicleicons\iconman_ca.paa", _enemyColor, _unitPos, pixelW * pixelGrid * 5, pixelH * pixelGrid * 5, 0];
		if(_centroid isNotEqualTo [0, 0, 0]) then {
			drawLine3D[_centroid, _unitPos, [0, 0, 1, 1], 6];
		};

		private _coverData = _unit getVariable[QGVAR(coverData), []];
		if(_coverData isNotEqualTo []) then {
			_coverData params["_coverObj", "_coverPos"];
			drawIcon3D ["", [1,0.23,1,1], _unitPos vectorAdd[0,0,2.6], 1, 1, 0, format["Cover:%1", _unit getVariable[QGVAR(isInCover), false]]];
			drawLine3D[_unitPos, _coverPos, [0, 1, 0, 1]];
			[_coverObj] call FUNC(debugCover);
		};

		private _player = [_unit, allPlayers + ([side _unit] call FUNC(getAllSideCorpses))] call FUNC(unitDetectEntities);
		if(!isNull _player) then {
			drawLine3D[_unit modelToWorldVisual EYE_OFFSET, _player modelToWorldVisual EYE_OFFSET, [_threat max _body_threat, 1 - (_threat max _body_threat), 0, 1]];
		};
	};

	allDeadMen apply {
		if(_x getVariable[QGVAR(kia), false]) then {
			drawIcon3D ["", [1,0,0,1], (getPos _x) vectorAdd[0,0,0.4], 1, 1, 0, "KIA"];
		};
	};
};
}, 0, []] call CBA_fnc_addPerFrameHandler;

debug_PFH_handle
