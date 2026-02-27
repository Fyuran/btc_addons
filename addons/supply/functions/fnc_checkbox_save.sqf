#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_save

Description:
    Returns the current checked status of a checkbox control.

Parameters:
    _checkbox[CONTROL]: Checkbox control to query

Returns:
    BOOLEAN: True if checkbox is checked, false otherwise

Examples:
    (begin example)
        _isDamageAllowed = [_damageCheckbox] call btc_supply_fnc_checkbox_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkbox", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox save", __FILE_NAME__], LOGS, "supply"] call EFUNC(tools,debug);
#endif
cbChecked _checkbox
