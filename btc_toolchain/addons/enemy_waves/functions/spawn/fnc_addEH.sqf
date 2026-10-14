#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_spawn_addEH

Description:
    Adds several Event Handlers to spawned units

Parameters:
    _units: OBJECT, ARRAY or GROUP - Unit, array of units, or group to add event handlers to

Returns:

Examples:
    (begin example)
        [_units] call btc_toolchain_enemy_waves_fnc_spawn_addEH;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[ 
	["_units", objNull, [objNull, [], grpNull]]
];

if (_units isEqualType objNull) then {
    _units = [_units];
};

if (_units isEqualType grpNull) then {
    _units = units _units;
};

private _fnc = { 
    params ["_unit"];
    private _logic = _unit getVariable[QGVAR(wave_spawn), objNull];
    private _units = _logic getVariable[QGVAR(wave_units), []];
    private _index = _units find _unit; 
    _units deleteAt _index;

    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: Removing %2(%3) from %4", __FILE_NAME__, _unit, _logic, _units], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif

    _logic setVariable[QGVAR(wave_units), _units];
};

_units apply {
    private _unit = _x;

    if (isNull _unit) then {
        #ifdef BTC_DEBUG_ENEMY_WAVES
        [["%1: _unit is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        continue;
    };

    _unit addEventHandler["Killed", _fnc]; 
    _unit addEventHandler["Deleted", _fnc];
};
