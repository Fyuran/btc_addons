#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_add

Description:
    Performs waypoint addition

Parameters:
    _group: GROUP
    _wpAttributes: ARRAY

Returns:

Examples:
    (begin example)
        [group this, []] call btc_toolchain_enemy_waves_fnc_wp_add;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_group", grpNull, [grpNull]],
    ["_wpAttributes", [], [[]]]
]; 

_wpAttributes = _wpAttributes apply {
    [_x] call FUNC(wp_processAttribute);
};

_wpAttributes params [
    ["_position", [0, 0, 0], [[]], 3],
    ["_type_data", [[], "MOVE"], [[]], 2],
	["_combat_mode", "NO CHANGE", [""]],
	["_behavior", "AWARE", [""]],
	["_formation", "NO CHANGE", [""]],
	["_speed", "UNCHANGED", [""]],
    ["_completion_radius", 0, [123]],
    ["_script", "", ["", {}]]
];

if(isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (_position isEqualTo [0, 0, 0]) exitWith {
	[["%1: found _position at [0, 0, 0]", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Prevent empty
private _type = _type_data param[1, "MOVE", [""]];
if (_type isEqualTo "") then {
    _type = "MOVE";
};
if (_combat_mode isEqualTo "") then {
    _combat_mode = "YELLOW";
};
if (_behavior isEqualTo "") then {
    _behavior = "AWARE";
};
if (_formation isEqualTo "") then {
    _formation = "NO CHANGE";
};
if (_speed isEqualTo "") then {
    _speed = "UNCHANGED";
};

//setWaypointScript only accepts STRING, so convert CODE
if (!(_script isEqualType {})) then {
    _script = str _script;
};
//Force type to 'SCRIPTED' if script is passed
if (_script isNotEqualTo "") then {
    _type = "SCRIPTED";
};

private _wp = _group addWaypoint [_position, -1];
_wp setWaypointType _type;
_wp setWaypointCombatMode _combat_mode; 
_wp setWaypointBehaviour _behavior; 
_wp setWaypointFormation _formation; 
_wp setWaypointSpeed _speed;
_wp setWaypointCompletionRadius _completion_radius;
_wp setWaypointScript _script;

_wp
