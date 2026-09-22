#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_c4booby_fnc_removeActions

Description:
    Removes ACE interaction actions previously registered on the defuser object.

Parameters:
    _defuser: OBJECT

Returns:
    BOOLEAN

Examples:
    (begin example)
        [_defuser] call btc_toolchain_c4booby_fnc_removeActions;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

if(!params[
	["_defuser",objNull,[objNull]]
]) exitWith{
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_actionIDS = _defuser getVariable [QGVAR(actionids),[]];
if(_actionIDS isEqualTo []) exitWith {
    [["%1: bad action ids: %2", __FILE_NAME__, _actionIDS], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_actionIDS apply {[_defuser, 0, _x] call ACEFUNC(interact_menu,removeActionFromObject);};

true
