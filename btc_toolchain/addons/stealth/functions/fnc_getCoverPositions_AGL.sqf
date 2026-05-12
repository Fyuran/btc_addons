#include "..\script_component.hpp"
#define _MIN_ 0.25
#define _MAX_ 0.75
#define _MULTIPLIER_ 1.5

params[
    ["_object", objNull, [objNull]],
    ["_resolution", 0.25, [123]]
];

if((_resolution < _MIN_) || (_resolution > _MAX_)) exitWith {
	[["%1: _resolution is invalid should be between %2 and %3", __FILE_NAME__, _MIN_, _MAX_], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};
if(isNull _object) exitWith {
	[["%1: _object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};
private _isEvenlyDivisible = abs((_MAX_ / _resolution) - round(_MAX_ / _resolution)) < 0.0001;
if(!_isEvenlyDivisible) exitWith {
	[["%1: _resolution is not evenly divisible", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

private _boundingBox = boundingBoxReal [_object, "FireGeometry"];
_boundingBox params["_boxMin", "_boxMax", "_radius"];
_boxMin params["_xMin", "_yMin", "_zMin"];
_boxMax params["_xMax", "_yMax", "_zMax"];

//Top view where positions are at center of object provided z = 0
private _bottomLeft = [_xMin, _yMin, 0];
private _bottomRight = [_xMax, _yMin, 0];
private _topRight = [_xMax, _yMax, 0];
private _topLeft = [_xMin, _yMax, 0];

private _positions = [];
for "_i" from _MIN_ to _MAX_ step _resolution do {
    _positions pushBackUnique (
        (vectorLinearConversion [0, 1, _i, _bottomLeft, _bottomRight, true]) vectorMultiply _MULTIPLIER_
    );
    _positions pushBackUnique (
        (vectorLinearConversion [0, 1, _i, _bottomRight, _topRight, true]) vectorMultiply _MULTIPLIER_
    );
    _positions pushBackUnique (
        (vectorLinearConversion [0, 1, _i, _topRight, _topLeft, true]) vectorMultiply _MULTIPLIER_
    );
    _positions pushBackUnique (
        (vectorLinearConversion [0, 1, _i, _topLeft, _bottomLeft, true]) vectorMultiply _MULTIPLIER_
    );
};

//make sure positions are at a reasonable height
_positions = _positions apply {
    private _pos = _object modelToWorld _x;
    [_pos#0, _pos#1, 0]
};

//add extra positions
if(_object isKindOf "House") then {
    _positions = _positions + (_object buildingPos -1);
};

_positions
