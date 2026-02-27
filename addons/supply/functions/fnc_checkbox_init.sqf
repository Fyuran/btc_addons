#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_init

Description:
    Initializes a checkbox control and stores a reference to it in UI namespace for later access.

Parameters:
    _checkbox[CONTROL]: Checkbox control to initialize

Returns:
    NOTHING

Examples:
    (begin example)
        [_damageCheckbox] call btc_supply_fnc_checkbox_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkbox", controlNull, [controlNull]]
];
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox init", __FILE_NAME__], LOGS, "supply"] call EFUNC(tools,debug);
#endif
disableSerialization;

uiNamespace setVariable[QGVAR(checkbox), _checkbox];
