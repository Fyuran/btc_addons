#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_stealth_fnc_debug_clients

Description:
    Provides debug visualization for stealth system on client. Displays 3D icons 
    for all players, threat levels for stealth units, line-of-sight indicators, 
    and event markers (suppressed, killed, hit, fired) with X-seconds duration.

Parameters:
    _groups - Array of stealth groups to monitor [Array, default: []]

Returns:
    None

Examples:
    (begin example)
        [grp_1] call btc_toolchain_stealth_fnc_debug_clients;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_groups", [], [[]]]
];

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

GVAR(removeEH_clients_handle) = [QGVAR(debug_removeEHs), _fnc_removeEh] call CBAFUNC(addEventHandler);

_groups apply {
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
			[QGVAR(debug_removeEHs), [_unit]] call CBAFUNC(localEvent);
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

GVAR(debug_PFH_handle) = [{
private _groups = (_this#0);
_groups apply {
	private _group = _x;
	if(!(_group getVariable[QGVAR(isEnabled), false])) then {
		_groups deleteAt (_groups find _group);
		continue;
	};
	(units _group) apply {
		private _unit = _x;
		private _unitStanceFactor = switch(stance _unit) do {
			case "PRONE": {0.5};
			case "CROUCH": {1};
			case "STAND": {1};
			default {1.5}
		};
		private _unitPos = _unit modelToWorldVisual[0, 0, _unitStanceFactor];
		private _threat = _unit getVariable[QGVAR(threat), 0];

		drawIcon3D ["", [1,0,0,1], _unitPos, pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "X"];
		drawIcon3D ["", [0,1,1,1], _unitPos vectorAdd[0,0,2], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, format["THREAT:%1", _threat]];

		if(!alive _unit) then {continue};
		allPlayers apply {
			private _player = _x;
			private _playerStance = stance _player;
			private _playerStanceFactor = switch(_playerStance) do {
				case "PRONE": {0.5};
				case "CROUCH": {1};
				case "STAND": {1};
				default {1.5}
			};
			drawIcon3D ["", [0,0,1,1], _player modelToWorldVisual[0, 0, _playerStanceFactor], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, "X"];
			private _playerPos = _player modelToWorldVisual[0, 0, _playerStanceFactor];
			private _unitToPlayer = _playerPos vectorDiff _unitPos;
			//vectorDir is normalized to account for model scale
			private _dotProduct = ((vectorNormalized(vectorDir _unit)) vectorAdd [0, 0, _playerStanceFactor]) vectorDotProduct (vectorNormalized _unitToPlayer); 			
			private _distance = vectorMagnitude _unitToPlayer;					
					
			if(_distance <= GVAR(threat_distance) && {_dotProduct > 0}) then {
				private _intersects = lineIntersectsSurfaces [
					_unit modelToWorldVisualWorld[0, 0, _unitStanceFactor], 
					_player modelToWorldVisualWorld[0, 0, _playerStanceFactor], 
					_unit, 
					_player
				];
				if(_intersects isEqualTo []) then {
					drawLine3D [
						_unitPos, 
						_playerPos,
						switch(_playerStance) do {
							case "PRONE": {[1 - _threat, 0, _threat, 1]};
							case "CROUCH": {[0, _threat, 1 - _threat, 1]};
							case "STAND": {[_threat, 1 - _threat, 0, 1]};
							default {[_threat, 1 - _threat, 0, 1]}
						}, 
						6
					];
				};  
			};
		};
	};
};
}, 0, _groups] call CBAFUNC(addPerFrameHandler);
