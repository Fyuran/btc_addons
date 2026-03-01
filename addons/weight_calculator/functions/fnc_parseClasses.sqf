#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
	Function: btc_toolchain_weight_calculator_parseClasses
	
	Description:
	    Retrieves list of JSON files and allow saving, deleting or copying
	
	Parameters:
	
	Returns:
	
	Examples:
	    (begin example)
	        [] call btc_toolchain_weight_calculator_parseClasses;
	    (end)
	
	Author:
	    Fyuran

---------------------------------------------------------------------------- */

params[
	["_loadout", [], [[], ""]],
	["_arr", [], [[]]]
];
if(_loadout isEqualTo []) exitWith {};
if(_loadout isEqualTo "") exitWith {};
if(_loadout isEqualType "") exitWith {};

_loadout apply {
	if(_x isEqualType []) then {
		if(_x isEqualTo []) then {continue};
		[_x, _arr] call FUNC(parseClasses);
	} else {
		if(_x isEqualTo "") then {continue};
		_arr pushBack _x;
	};
};
