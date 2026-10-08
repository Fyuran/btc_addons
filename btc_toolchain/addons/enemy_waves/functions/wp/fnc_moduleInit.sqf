#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_moduleInit

Description:
    Used to init waypoint modules for passed groups

Parameters:
    _logic: OBJECT
    _group: GROUP

Returns:

Examples:
    (begin example)
        [this, group this] call btc_toolchain_enemy_waves_fnc_wp_moduleInit;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[ 
	["_logic", objNull, [objNull]],
    ["_group", grpNull, [grpNull]]
]; 

if(isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (isNull _group) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

//Add wps from wp modules first
private _synchedObjs = synchronizedObjects _logic;
_synchedObjs = _synchedObjs select {_x isKindOf QGVAR(waypoint_module)};

//no need to retrieve them back once they are cached
private _wpModules = _logic getVariable[QGVAR(wpModules), []];
if (_synchedObjs isNotEqualTo [] && {(_wpModules isEqualTo [])}) then {
    [_synchedObjs#0, _wpModules] call FUNC(wp_getNextModule);
    _logic setVariable[QGVAR(wpModules), _wpModules];
};

_wpModules apply {
    [
        _group,
        getPosASL _x,
        _x getVariable[QGVAR(wp_cfg), configNull],
        _x getVariable[QGVAR(completion_radius), 0],
        _x getVariable[QGVAR(file), ""],
        [

            _x getVariable[QGVAR(combat_mode), "NO CHANGE"],
            _x getVariable[QGVAR(behavior), "UNCHANGED"],
            _x getVariable[QGVAR(formation), "NO CHANGE"],
            _x getVariable[QGVAR(speed), "UNCHANGED"]
        ]
    ] call FUNC(wp_add);
};

//Last one to seek a player
if (_logic getVariable[QGVAR(seek_end), true]) then {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: %2 is on the lookout for player", __FILE_NAME__, _group], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    [_group] call FUNC(wp_toPlayer);
};
