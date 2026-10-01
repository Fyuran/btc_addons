#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_checkbox_init

Description:
    Initializes a checkbox control and stores a reference to it in UI namespace for later access.

Parameters:
    _checkbox[CONTROL]: Checkbox control to initialize

Returns:
    NOTHING

Examples:
    (begin example)
        [_damageCheckbox] call btc_toolchain_supply_fnc_checkbox_init;
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
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
disableSerialization;

uiNamespace setVariable[QGVAR(checkbox), _checkbox];
