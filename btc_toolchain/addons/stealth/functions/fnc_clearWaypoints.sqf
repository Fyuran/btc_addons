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

[_group, currentWaypoint _group] setWaypointPosition [getPosASL leader _group, -1];
{ deleteWaypoint _x } forEachReversed waypoints _group; 
