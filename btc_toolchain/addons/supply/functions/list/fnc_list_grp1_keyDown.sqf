#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp1_keyDown

Description:
    Handles KeyDown event on LIST_1 to copy selected object's class to clipboard (Ctrl+C).

Parameters:
    _grp1_list: CONTROL
    _key: NUMBER
    _shift: BOOLEAN
    _ctrl: BOOLEAN
    _alt: BOOLEAN

Returns:
    BOOLEAN

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_grp1_list", "_key", "_shift", "_ctrl", "_alt"];

if (_key isEqualTo 0x2E && {_ctrl}) then {
    //retrieve LIST_1 lbCurSel's data from the HashMap
    private _uid = _grp1_list lbData (lbCurSel _grp1_list);
    private _class = (GVAR(table) get _uid) get "class";
    if (_class isEqualTo "") exitWith {
        ["Could not copy to clipboard selected class"] call EFUNC(tools,3DENNotification);
    };
    [format["%1 class saved into clipboard", _class]] call EFUNC(tools,3DENNotification);
    copyToClipboard _class;
    false
};

