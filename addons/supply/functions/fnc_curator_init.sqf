#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_curator_init

Description:
    Initializes the supply module when synced with a curator.

Parameters:
    _logic[OBJECT]: Module logic object
    _units[ARRAY]: Array of affected units
    _activated[BOOLEAN]: True when activated, false when deactivated

Returns:
    NOTHING

Examples:
    (begin example)
        [] call btc_supply_fnc_curator_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];

if(isNull _logic) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if(!_activated) exitWith {};
//diag_log format["_logic owner is %1", owner _logic];
missionNamespace setVariable[QGVAR(logic), _logic, owner _logic];
