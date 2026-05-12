#include "..\script_component.hpp"

//Should be used only with getBoundingBoxFaces_Model's return
params[
    ["_object", objNull, [objNull]]
];
if(isNull _object) exitWith {
	[["%1: _obj is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};	
 
private _coverPositions = [_object] call FUNC(getCoverPositions_AGL);
private _faces = [_object] call FUNC(getBoundingBoxFaces_Model);
private _bottomPoints = _faces get "Bottom";
private _topPoints = _faces get "Top";

private _size = count _bottomPoints;
for "_i" from 0 to (_size - 1) do {
    private _start = _object modelToWorld (_bottomPoints select _i);
    private _end = _object modelToWorld (_bottomPoints select ((_i + 1) mod _size));
    drawLine3D [_start, _end, [0,0,1,1]];
    drawIcon3D ["", [1,0,0,1], _start vectorAdd [0, 0, 0.1], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, str _i];

    _start = _object modelToWorld (_topPoints select _i);
    _end = _object modelToWorld (_topPoints select ((_i + 1) mod _size));
    drawLine3D [_start, _end, [0,0,1,1]];
    drawIcon3D ["", [1,0,0,1], _start vectorAdd [0, 0, 0.1], pixelW * pixelGrid * 1, pixelH * pixelGrid * 1, 0, str _i];

    _start = _object modelToWorld (_topPoints select _i);
    _end = _object modelToWorld (_bottomPoints select _i);
    drawLine3D [_start, _end, [0,0,1,1]];
};

_coverPositions apply {
    private _position = _x;
    private _isSafe = true;
    allPlayers apply {
        if(!([AGLToASL _position, _x] call FUNC(isPositionHidden_ASL))) then {
            _isSafe = false;
            break;
        };
    };
    private _color = [[1,0,0,1], [0,1,0,1]] select _isSafe;
    drawIcon3D ["", _color, _position, 1, 1, 0, "C"];
};
