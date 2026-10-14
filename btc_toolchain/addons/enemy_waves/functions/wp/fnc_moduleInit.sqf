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
    private _type_data = _x getVariable[QGVAR(type_data), [[], "MOVE"]]; //Tree saves as Attribute in .sqm as [TREEPATH, TREEPATH_TEXT]
    [_group, 
        [
            getPosASL _x,
            _type_data#1, 
            _x getVariable[QGVAR(combat_mode), "YELLOW"],
            _x getVariable[QGVAR(behavior), "AWARE"],
            _x getVariable[QGVAR(formation), "NO CHANGE"],
            _x getVariable[QGVAR(speed), "UNCHANGED"],
            _x getVariable[QGVAR(completion_radius), 0]
        ]
    ] call FUNC(wp_add);
};

//Last one to seek a player
if (_logic getVariable[QGVAR(seek_end), true]) then {
    [_logic, _group] call FUNC(wp_toPlayer);
};
