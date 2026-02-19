#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_checkbox_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkbox", controlNull, [controlNull]]
];
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["% 1: executing checkbox init", __FILE_NAME__], CHAT, "supply"] call EFUNC(tools,debug);
#endif
disableSerialization;

uiNamespace setVariable[QGVAR(checkbox), _checkbox];

_checkbox ctrlAddEventHandler["CheckedChanged", {
    params ["_checkbox", "_checked"]; //checked is a SCALAR value, either 0 for false or 1 for true

    missionNamespace setVariable[QGVAR(table_allowDamage), [false, true] select _checked];
}];
