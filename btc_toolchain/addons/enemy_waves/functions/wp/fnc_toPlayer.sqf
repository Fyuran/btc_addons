#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_toPlayer

Description:
    Usually the last waypoint for the group, will endlessly seek out nearest player group leader

Parameters:
    _group: GROUP - Group to assign player seeking waypoint to

Returns:

Examples:
    (begin example)
        [group this] call btc_toolchain_enemy_waves_fnc_wp_toPlayer;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_group", grpNull, [grpNull]]
]; 

if(isNull _group) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

//find group leaders
private _hostileSides = [side _group] call BIS_fnc_enemySides;
if (_hostileSides isEqualTo []) exitWith {};

private _players = (allPlayers select {
    (alive _x ) && {(side _x) in _hostileSides}
}) - entities "HeadlessClient_F";

if (_players isEqualTo []) exitWith {};

private _playerLeaders = [];
_players apply {
    _playerLeaders pushBackUnique leader _x;
};

//Sort by closest and select him
_playerLeaders = [_playerLeaders, [leader _group], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;
if (_playerLeaders isEqualTo []) exitWith {};
private _leader = _playerLeaders select 0;

if (isNull _leader) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: found _leader is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _wp = [_group, [getPosASL _leader]] call FUNC(wp_add); //keeping other params as default should suffice

//Endless hunt
_wp setWaypointStatements ["true", QUOTE([group this] call FUNC(wp_toPlayer))];
