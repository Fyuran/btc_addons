#include "..\script_component.hpp"

params[
	["_unit", objNull, [objNull]],
	["_entities", [], [objNull, []]],
	["_range", (_this#0) getVariable[QGVAR(threat_distance), THREAT_DISTANCE], [123]]
];
private _return = objNull;

if(_unit getVariable ["ACE_isUnconscious", false]) exitWith {_return};
if(!alive _unit) exitWith {_return};
if(_range <= 0) exitWith {
	[["%1: _range is zero or neg", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	_return
};

if(!(_entities isEqualType [])) then {
	_entities = [_entities];
};
/* if(!(_entities isEqualTypeAll objNull)) exitWith {
	[["%1: _entities should be all of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
}; */

private _unitPosASL = eyePos _unit;

_entities apply {
	if(isNull _x) then {
		break;
	};
	private _entity = vehicle _x;
	if(_entity getVariable[QGVAR(kia), false]) then { //used for allDeadMen
		break;
	};
	private _entityPosASL = getPosASL _entity;
	if(_entity isKindOf "CAManBase") then {
		_entityPosASL = eyePos _entity;
	};
	private _unitToEntity = _entityPosASL vectorDiff _unitPosASL;
	//vectorDir is also normalized to account for model scale
	private _dotProduct = (vectorNormalized(eyeDirection _unit)) vectorDotProduct (vectorNormalized _unitToEntity);			 
	private _distance = vectorMagnitude _unitToEntity;					

	if(_distance < 30 && {(speed _entity) > 11}) then { //audible range
		_return = _entity;
		break;
	};
	if(_distance <= _range && {_dotProduct > 0}) then {
		private _intersects = lineIntersectsSurfaces [
			_unitPosASL, 
			_entityPosASL, 
			_unit, 
			_entity
		];
		if(_intersects isEqualTo []) then {
			_return = _entity;
			break;
		};  
	};
};

_return
