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
    ["_position", [0, 0, 0], [[]], 3],
    ["_wp_cfg", DEFAULT_CFG, [configNull, ""]],
    ["_completion_radius", 0, [123]],
    ["_script", "", ["", {}]],
    ["_wpAttributes", [], [[]]]
]; 

_wpAttributes = _wpAttributes apply {
    [_x] call FUNC(wp_processAttribute);
};

_wpAttributes params [ //parse cfg properties
	["_combat_mode", "NO CHANGE", [""]],
	["_behavior", "UNCHANGED", [""]],
	["_formation", "NO CHANGE", [""]],
	["_speed", "UNCHANGED", [""]]
];

if(isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (_position isEqualTo [0, 0, 0]) exitWith {
	[["%1: found _position at [0, 0, 0]", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _type = "MOVE"; //Prevent empty
if (_wp_cfg isEqualType "") then {
    _wp_cfg = [_wp_cfg] call EFUNC(tools,strToCfg);
};
if (!(isNull _wp_cfg) && {isClass _wp_cfg}) then {
    _type = getText (_wp_cfg >> "type");
    _script = getText (_wp_cfg >> "file");
};
if (_type isEqualTo "") then {
    _type = "MOVE";
};
if (_combat_mode isEqualTo "") then {
    _combat_mode = "NO CHANGE";
};
if (_behavior isEqualTo "") then {
    _behavior = "UNCHANGED";
};
if (_formation isEqualTo "") then {
    _formation = "NO CHANGE";
};
if (_speed isEqualTo "") then {
    _speed = "UNCHANGED";
};

//setWaypointScript only accepts STRING, so convert CODE
if (_script isEqualType {}) then {
    _script = str _script;
};
//Force type to 'SCRIPTED' if script is passed
if (_script isNotEqualTo "") then {
    _type = "SCRIPTED";
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: adding _wp with data: %2", __FILE_NAME__, [_group, _type, _position, _wp_cfg, 
    _completion_radius, _script, _combat_mode, _behavior, _formation, _speed]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _wp = _group addWaypoint [_position, -1]; 
_wp setWaypointType _type;
_wp setWaypointCombatMode _combat_mode; 
_wp setWaypointBehaviour _behavior; 
_wp setWaypointFormation _formation; 
_wp setWaypointSpeed _speed;
_wp setWaypointCompletionRadius _completion_radius;
_wp setWaypointScript _script;

_wp
