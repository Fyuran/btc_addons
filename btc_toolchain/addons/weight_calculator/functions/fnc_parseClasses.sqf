#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_weight_calculator_fnc_parseClasses

Description:
    Recursively parses inventory loadout array and extracts non-empty classnames into a target array.

Parameters:
    _loadout: ARRAY/STRING
    _arr: ARRAY

Returns:

Examples:
    (begin example)
        private _classes = [];
        [getUnitLoadout player, _classes] call btc_toolchain_weight_calculator_fnc_parseClasses;
    (end)

Author:
    =BTC= Fyuran

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
