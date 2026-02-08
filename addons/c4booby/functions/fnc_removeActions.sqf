#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_c4booby_fnc_removeActions

Description:
    Helper function that removes actions from a single barrel and its phone

Parameters:


Returns:

Examples:
    (begin example)
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!params[
	["_defuser",objNull,[objNull]]
]) exitWith{
    [["%1: bad params: %2", __FILE__, _this], 6, "c4booby"] call EFUNC(tools,debug);
};

_actionIDS = _defuser getVariable ["c4booby_actionids",[]];
if(_actionIDS isEqualTo []) exitWith {
    [["%1: bad action ids: %2", __FILE__, _actionIDS], 6, "c4booby"] call EFUNC(tools,debug);
};
_actionIDS apply {[_defuser,0,_x] call ace_interact_menu_fnc_removeActionFromObject};

true
