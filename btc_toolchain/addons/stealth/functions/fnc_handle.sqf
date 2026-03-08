#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_stealth_fnc_handle

Description:
    Per-frame handler that manages threat detection for stealth units. Monitors 
    line of sight to all players and calculates threat based on distance, stance, 
    and visibility. Triggers alarm when threat reaches threshold. Naturally 
    decreases threat when no player is in sight.

Parameters:
    _groups - Array of stealth groups to monitor [Array, default: []]

Returns:
    None

Examples:
    (begin example)
        [grp_1] call btc_toolchain_stealth_fnc_handle;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_groups", [], [[]]]
];

GVAR(PFH_handle) = [{
private _groups = (_this#0);
if(_groups isEqualTo []) exitWith {
	[_this#1] call CBAFUNC(removePerFrameHandler);
}; 
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
		private _unitPos = _unit modelToWorld[0, 0, _unitStanceFactor];
		private _threat = _unit getVariable[QGVAR(threat), 0];
		if(!alive _unit || _threat >= 1) then {continue};
		private _hasPlayerInSight = false;

		allPlayers apply {
			private _player = _x;
			private _playerStance = stance _player;
			private _playerStanceFactor = switch(_playerStance) do {
				case "PRONE": {0.5};
				case "CROUCH": {1};
				case "STAND": {1};
				default {1.5}
			};
			private _playerPos = _player modelToWorld[0, 0, _playerStanceFactor];
			private _unitToPlayer = _playerPos vectorDiff _unitPos;
			//vectorDir is normalized to account for model scale
			private _dotProduct = ((vectorNormalized(vectorDir _unit)) vectorAdd [0, 0, _playerStanceFactor]) vectorDotProduct (vectorNormalized _unitToPlayer); 			
			private _distance = vectorMagnitude _unitToPlayer;					
					
			if(_distance <= GVAR(threat_distance) && {_dotProduct > 0}) then {
				private _intersects = lineIntersectsSurfaces [
					_unit modelToWorldWorld[0, 0, _unitStanceFactor], 
					_player modelToWorldWorld[0, 0, _playerStanceFactor], 
					_unit, 
					_player
				];
				if(_intersects isEqualTo []) then {
					private _playerStanceThreatFactor = switch(_playerStance) do {
						case "PRONE": {0.5};
						case "CROUCH": {0.75};
						case "STAND": {1};
						default {1}
					};
					_threat = (_threat + (((THREAT_FACTOR * _playerStanceThreatFactor) / (_distance + 1)) * diag_deltaTime)) min 1;
					_hasPlayerInSight = true;
					_unit setVariable[QGVAR(threat), _threat, GVAR(debug)];
				};  
			};
		};
		if(_threat >= 1) then {
			[QGVAR(goCombatEvent), [_group]] call CBAFUNC(localEvent);
		} else {
			if(!_hasPlayerInSight) then {
				_threat = (_threat - (0.1 * diag_deltaTime)) max 0;
				_unit setVariable[QGVAR(threat), _threat, GVAR(debug)];
			};
		}; 
	};
};
}, 0, _groups] call CBAFUNC(addPerFrameHandler);

if(GVAR(debug)) then {
	GVAR(debug_JIP) = [_groups] remoteExecCall [QFUNC(debug), [0, -2] select isDedicated, true];
};
