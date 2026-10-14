#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_list_keyDown

Description:
    Handles KeyDown events on list controls for copying selected text/data to clipboard
    (Ctrl+C) and tracking shift key modifier.

Parameters:
    _ctrlList: CONTROL - List control (ListBox or ListNBox)
    _key: NUMBER - Key code
    _shift: BOOLEAN - Shift key pressed
    _ctrl: BOOLEAN - Ctrl key pressed
    _alt: BOOLEAN - Alt key pressed

Returns:
    BOOLEAN - True if handled

Examples:
    (begin example)
        [_listControl, 0x2E, false, true, false] call btc_toolchain_gui_fnc_list_keyDown;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params ["_ctrlList", "_key", "_shift", "_ctrl", "_alt"];

if (_key isEqualTo 0x2E && {_ctrl}) then {
    private _text = "";
    if (ctrlType _ctrlList isEqualTo 102) then {
        private _row = lnbCurSelRow _ctrlList;
        if (_row >= 0) then {
            _text = _ctrlList lnbData [_row, 0];
            if (_text isEqualTo "") then {
                _text = _ctrlList lnbText [_row, 0];
            };
        };
    } else {
        private _curSel = lbCurSel _ctrlList;
        if (_curSel >= 0) then {
            _text = _ctrlList lbData _curSel;
            if (_text isEqualTo "") then {
                _text = _ctrlList lbText _curSel;
            };
        };
    };

    if (_text isNotEqualTo "") then {
        [format ["%1 class saved into clipboard", _text]] call EFUNC(tools,3DENNotification);
        copyToClipboard _text;
    };
    false
};


missionNamespace setVariable [QGVAR(shift_modifier), _shift];

#ifdef BTC_DEBUG_GUI
[["%1: _keyDown: %2, _shift: %3", __FILE_NAME__, _key, _shift], CHAT, QCOMPONENT] call EFUNC(tools,debug);
#endif

false

