#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_list_keyUp

Description:
    Handles KeyUp events on list controls to reset the shift key modifier.

Parameters:
    _ctrlList: CONTROL - List control
    _key: NUMBER - Key code
    _shift: BOOLEAN - Shift key pressed
    _ctrl: BOOLEAN - Ctrl key pressed
    _alt: BOOLEAN - Alt key pressed

Returns:
    BOOLEAN

Examples:
    (begin example)
        [_listControl, 0x2A, false, false, false] call btc_toolchain_gui_fnc_list_keyUp;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_ctrlList", "_key", "_shift", "_ctrl", "_alt"];

missionNamespace setVariable [QGVAR(shift_modifier), _shift];

#ifdef BTC_DEBUG_GUI
[["%1: _keyUp: %2, _shift: %3", __FILE_NAME__, _key, _shift], CHAT, QCOMPONENT] call EFUNC(tools,debug);
#endif

false

