#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_list_arrowAdjust

Description:
    Universal quantity increment/decrement handler for two-list controls groups.
    Updates the UI amount column and invokes the module callback with the new amount.

Parameters:
    _btn: CONTROL - The arrow button control clicked
    _isIncrement: BOOLEAN - True to increment, false to decrement
    _onUpdate: CODE - Callback invoked with [_grp1_key, _grp2_class, _newAmount, _grp1_curSel, _grp2_curSelRow]

Returns:
    NOTHING

Examples:
    (begin example)
        [_btn, true, _onUpdateCallback] call btc_toolchain_gui_fnc_list_arrowAdjust;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_btn", controlNull, [controlNull]],
    ["_isIncrement", true, [true]],
    ["_onUpdate", {}, [{}]]
];

private _grp2 = ctrlParentControlsGroup _btn;
private _main_grp = ctrlParentControlsGroup _grp2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

private _grp1_curSel = lbCurSel _grp1_list;
if (_grp1_curSel < 0) exitWith {
    ["Nothing is selected in the first list", 1] call EFUNC(tools,3DENNotification);
};

private _grp2_curSelRow = lnbCurSelRow _grp2_list;
if (_grp2_curSelRow < 0) exitWith {
    ["Nothing is selected in the second list", 1] call EFUNC(tools,3DENNotification);
};

private _grp1_key = _grp1_list lbData _grp1_curSel;
private _grp2_class = _grp2_list lnbData [_grp2_curSelRow, 0];

private _currentText = _grp2_list lnbText [_grp2_curSelRow, 1];
private _currentAmount = parseNumber _currentText;

private _step = [1, 5] select (missionNamespace getVariable [QGVAR(shift_modifier), false]);
private _newAmount = if (_isIncrement) then {
    _currentAmount + _step
} else {
    (_currentAmount - _step) max 1
};

_grp2_list lnbSetText [[_grp2_curSelRow, 1], str _newAmount];

[_grp1_key, _grp2_class, _newAmount, _grp1_curSel, _grp2_curSelRow] call _onUpdate;

