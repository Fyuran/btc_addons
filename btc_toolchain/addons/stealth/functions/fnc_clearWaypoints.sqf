#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_clearWaypoints

Description:
    Clears all waypoints from an AI group and sets its current waypoint position to the leader's position.

Parameters:
    _group: GROUP/OBJECT

Returns:

Examples:
    (begin example)
        [_group] call btc_toolchain_stealth_fnc_clearWaypoints;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_group", grpNull, [grpNull, objNull]]
];

if (isNull _group) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    []
};
if(_group isEqualType objNull) then {
    _group = group _group;
};

[_group, currentWaypoint _group] setWaypointPosition [getPosASL leader _group, -1];
{ deleteWaypoint _x } forEachReversed waypoints _group; 
