#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_init

Description:
    Used to configure a waypoint module

Parameters:
    _logic: OBJECT

Returns:

Examples:
    (begin example)
        [this] call btc_toolchain_enemy_waves_fnc_wp_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[ 
	["_logic", objNull, [objNull]]
]; 

if(isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: Should be run only on Server", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!(_logic isKindOf "Module_F")) exitWith {
	[["%1: _logic is not a Module_F", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _synchedObjs = synchronizedObjects _logic;
if(_synchedObjs isEqualTo []) exitWith {
	[["%1: No linked objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(!(_synchedObjs isEqualTypeAll objNull)) exitWith {
	[["%1: Linked types aren't of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

