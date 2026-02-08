#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_save

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_checkbox_save;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkbox", controlNull, [controlNull]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox save", __FILE__], 2, "supply"] call EFUNC(tools,debug);
#endif
cbChecked _checkbox
