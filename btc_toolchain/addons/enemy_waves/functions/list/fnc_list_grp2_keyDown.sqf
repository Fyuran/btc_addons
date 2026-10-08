#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_grp2_keyDown

Description:
    Handles KeyDown events for the classes listbox, copying the selected class to clipboard with Ctrl+C.

Parameters:
    _grp2_list: CONTROL - The classes listbox control
    _key: NUMBER - Key code
    _shift: BOOLEAN - Shift key pressed
    _ctrl: BOOLEAN - Ctrl key pressed
    _alt: BOOLEAN - Alt key pressed

Returns:
    BOOLEAN

Examples:
    (begin example)
        [_listControl, 0x2E, false, true, false] call btc_toolchain_enemy_waves_fnc_list_grp2_keyDown;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_grp2_list", controlNull, [controlNull]],
    ["_key", -1, [0]],
    ["_shift", false, [true]],
    ["_ctrl", false, [true]],
    ["_alt", false, [true]]
];

if (_key isEqualTo 0x2E && {_ctrl}) exitWith {
    //retrieve LIST_1 lbCurSel's data from the HashMap
    private _class = _grp2_list lnbData [(lnbCurSelRow _grp2_list), 0];
    [format["%1 class saved into clipboard", _class]] call EFUNC(tools,3DENNotification);
    copyToClipboard _class;
    false
};

false

