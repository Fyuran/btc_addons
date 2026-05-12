#include "..\script_component.hpp"

params [
    ["_group", grpNull, [grpNull, objNull]]
];

if (isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};
if(_group isEqualType objNull) then {
    _group = group _group;
};
private _wps = waypoints _group;
private _waypointsArray = [];

if(_wps isEqualTo []) exitWith {
    _waypointsArray
};

{
    private _radius = waypointCompletionRadius _x;
    private _pos = [waypointPosition _x, AGLToASL (waypointPosition _x)] select (_radius <= -1); //radius -1 uses posASL for whatever reason
    private _type = waypointType _x;
    private _wpData = [
        _forEachIndex,
        _pos,
        _radius,
        _type,
        waypointBehaviour _x,
        waypointCombatMode _x,
        waypointSpeed _x,
        waypointFormation _x,
        waypointStatements _x,
        waypointTimeout _x,
        waypointCompletionRadius _x
    ];

    _waypointsArray pushBack _wpData;

} forEach _wps;

_waypointsArray
