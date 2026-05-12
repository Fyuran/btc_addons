#include "..\script_component.hpp"

//Includes both runtime and terrain objects
params[
	["_src", [0,0,0], [objNull, []]],
	["_direction", "ASCEND", [""]],
	["_distance", 50, [123]]
];

if((_direction isNotEqualTo "ASCEND") && (_direction isNotEqualTo "DESCEND")) exitWith {
	[["%1: _direction should be either 'ASCEND' or 'DESCEND'", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _terrainObjects = nearestTerrainObjects[_src, ["WATERTOWER", "HOSPITAL", "FORTRESS", "VIEW-TOWER", "BUILDING", "BUNKER", "WALL", "FENCE", "HOUSE", "RUIN", "CHAPEL", "CHURCH"], _distance, true];
private _objects = nearestObjects[_src, ["House"], _distance];

private _allObjects = [];
(_terrainObjects + _objects) apply {
	_allObjects pushBackUnique _x;
};

[_allObjects, [_src], { _input0 distanceSqr _x }, _direction] call BIS_fnc_sortBy
