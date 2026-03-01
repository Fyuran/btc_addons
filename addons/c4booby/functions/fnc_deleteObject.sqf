#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_c4booby_fnc_deleteObject

Description:
    Passed object is stripped of its attached objects, timer is halted and conditions are evaluated

Parameters:
    _obj : Object

Returns:

Examples:
    (begin example)
        [this] call btc_c4booby_fnc_deleteObject;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
	["_obj",objNull,[objNull]]
];
if(isNull _obj) exitWith {
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _handle = _obj getVariable [QGVAR(timer_handle), -1];
if(_handle != -1) then {
	[_handle] CBAFUNC(removePerFrameHandler);
};
private _objs = attachedObjects _obj;
_objs apply {deleteVehicle _x};
