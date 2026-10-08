#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_keyDown

Description:
    Handles KeyDown on LIST_2 for copy-to-clipboard (Ctrl+C) and shift modifier tracking.

Parameters:
    _grp2_list: CONTROL
    _key: NUMBER
    _shift: BOOLEAN
    _ctrl: BOOLEAN
    _alt: BOOLEAN

Returns:
    BOOLEAN

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_grp2_list", "_key", "_shift", "_ctrl", "_alt"];

if (_key isEqualTo 0x2E && {_ctrl}) then {
    private _class = _grp2_list lnbData[(lnbCurSelRow _grp2_list), 0];
    [format["%1 class saved into clipboard", _class]] call EFUNC(tools,3DENNotification);
    copyToClipboard _class;
    false
};
if (_shift) then {
    GVAR(shift_modifier) = true;
};

