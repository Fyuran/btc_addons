#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_checkbox_save

Description:
    Returns the current checked status of a checkbox control.

Parameters:
    _checkbox[CONTROL]: Checkbox control to query

Returns:
    BOOLEAN: True if checkbox is checked, false otherwise

Examples:
    (begin example)
        _isDamageAllowed = [_damageCheckbox] call btc_toolchain_supply_fnc_checkbox_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrl", controlNull, [controlNull, []], [1, 2]]
];
private _ctrlGroup = if (_ctrl isEqualType []) then {_ctrl select 0} else {_ctrl};
private _checkbox = if (ctrlIDC _ctrlGroup isEqualTo CHECKBOX) then {
    _ctrlGroup
} else {
    _ctrlGroup controlsGroupCtrl CHECKBOX
};
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox save", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
cbChecked _checkbox
