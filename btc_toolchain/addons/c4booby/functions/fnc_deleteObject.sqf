#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_c4booby_fnc_deleteObject

Description:
    Halts countdown timer and deletes all attached objects/parts from a defused or triggered bomb.

Parameters:
    _obj: OBJECT

Returns:

Examples:
    (begin example)
        [_bombObject] call btc_toolchain_c4booby_fnc_deleteObject;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
	["_obj",objNull,[objNull]]
];
if(isNull _obj) exitWith {
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _handle = _obj getVariable [QGVAR(timer_handle), -1];
if(_handle != -1) then {
	[_handle] call CBAFUNC(removePerFrameHandler);
};
private _objs = attachedObjects _obj;
_objs apply {deleteVehicle _x};
