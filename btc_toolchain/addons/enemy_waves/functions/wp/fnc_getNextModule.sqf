#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_getNextModule

Description:
    Traverse synched objects hierarchy, will recursively call itself until last waypoint module is reached

Parameters:
    _waypoint_module: OBJECT
    _toArray: ARRAY

Returns:

Examples:
    (begin example)
        [this, []] call btc_toolchain_enemy_waves_fnc_wp_getNextModule;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_waypoint_module", objNull, [objNull]],
    ["_toArray", [], [[]]]
]; 

if(!(_waypoint_module isKindOf QGVAR(waypoint_module))) exitWith {
	[["%1: _waypoint_module's type: %2 is not a valid btc_enemy_waves_waypoint_module type", __FILE_NAME__, typeOf _waypoint_module], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_waypoint_module setVariable[QGVAR(hasBeenProcessed), true];
_toArray pushBackUnique _waypoint_module;

private _synchedObjs = synchronizedObjects _waypoint_module;
_synchedObjs = _synchedObjs select {
    _x isKindOf QGVAR(waypoint_module) &&
    {!(_x getVariable[QGVAR(hasBeenProcessed), false])}
};

if (_synchedObjs isEqualTo []) exitWith {};

[_synchedObjs#0, _toArray] call FUNC(wp_getNextModule);
