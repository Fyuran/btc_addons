#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_c4booby_fnc_objectInit

Description:
    Helper function that adds actions to a single barrel and its defuser for examination

Parameters:


Returns:

Examples:
    (begin example)
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!params [
	["_defuser",objNull,[objNull]],
	["_obj",objNull,[objNull]]
]) exitWith {
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, "c4booby"] call EFUNC(tools,debug);
};

private _color_actions = [];
private _action_ids = [];

//Colors action are parsed through ACE action functions
["red","green","blue"] apply {
	private _action = [format["c4booby_%1",_x], format["Cut the %1 wire",_x], "",
	{
		params["_target","_caller","_args"];
		[1,	_args,
		{
			_args params ["_obj","_color"];
			private _inputed_colors = _obj getVariable ["input_wire_colors",[]];
			_inputed_colors pushBack _color;
			_obj setVariable ["input_wire_colors",_inputed_colors,true];

		}, {hint "Aborted"}, "Cutting"] call ace_common_fnc_progressBar;
	}, {true}, {}, [_obj,_x]] call ace_interact_menu_fnc_createAction;
	_color_actions pushBack _action;
};

//Examine action that will add colors actions upon examination
private _action = ["c4booby_examine", "Examine", "",
{
	_delay = [10, 1] select ("ACE_DefusalKit" in ((vestItems player) + (uniformItems player) + (backpackItems player)));
	[_delay, _this,
	{
		_args params ["_target","_caller","_params"];
		_params params ["_color_actions","_action_ids"];
		hint format["Cut the %1 wire",(_target getVariable ["wire_colors",["REPORT"]])select 0];
		if !(_target getVariable ["obj_hasActions",false]) then {
			_target setVariable ["obj_hasActions",true];
			_color_actions apply {
				private _action = [_target, 0, ["ACE_MainActions"], _x] call ace_interact_menu_fnc_addActionToObject;
				_action_ids pushBack _action;
			};
		};

	}, {hint "Aborted"}, "Examining"] call ace_common_fnc_progressBar;
}, {true}, {}, [_color_actions,_action_ids]] call ace_interact_menu_fnc_createAction;
_action = [_defuser, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
_action_ids pushBack _action;

_defuser setVariable ["c4booby_actionids",_action_ids];
