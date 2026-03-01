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
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_actionIDS = _defuser getVariable [QGAR(actionids),[]];
if(_actionIDS isEqualTo []) exitWith {
    [["%1: bad action ids: %2", __FILE_NAME__, _actionIDS], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_actionIDS apply {[_defuser, 0, _x] call ACEFUNC(interact_menu,removeActionFromObject);};

true
