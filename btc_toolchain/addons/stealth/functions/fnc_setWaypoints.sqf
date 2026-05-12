#include "..\script_component.hpp"

params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_waypointsArray", [], [[]]]
];

if (isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_group isEqualType objNull) then {
    _group = group _group;
};

[_group] call FUNC(clearWaypoints);
if (_waypointsArray isEqualTo []) exitWith {}; //clear wps only

{
    _x params [
        ["_index", -1, [123]],
        ["_pos", [0, 0, 0], [[]], 3],
        ["_radius", -1, [123]],
        ["_type", "MOVE", [""]],
        ["_behaviour", "UNCHANGED", [""]],
        ["_combat", "NO CHANGE", [""]],
        ["_speed", "UNCHANGED", [""]],
        ["_formation", "NO CHANGE", [""]],
        ["_statements", ["true", ""], [[]], 2],
        ["_timeout", [0,0,0], [[]], 3],
        ["_compRadius", 0, [123]]
    ];
    if(_pos isEqualTo [0, 0, 0]) then {
	    [["%1: found a wp leading to [0, 0, 0] for group %2", __FILE_NAME__, _group], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        continue;
    };

    private _wp = _group addWaypoint [_pos, _radius, _index];
    _wp setWaypointType _type;
    _wp setWaypointBehaviour _behaviour;
    _wp setWaypointCombatMode _combat;
    _wp setWaypointSpeed _speed;
    _wp setWaypointFormation _formation;
    _wp setWaypointStatements _statements;
    _wp setWaypointTimeout _timeout;
    _wp setWaypointCompletionRadius _compRadius;
} forEach _waypointsArray;
