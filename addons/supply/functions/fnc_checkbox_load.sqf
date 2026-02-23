#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_load

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_checkbox_load;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkbox", controlNull, [controlNull]],
    ["_value", true, [false, 123]]
];
disableSerialization;
#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["%1: executing checkbox load with _value %2", __FILE_NAME__, _value], LOGS, "supply"] call EFUNC(tools,debug);
#endif

if(_value isEqualType 123) then {
    if(_value > 1) exitWith {
        [["%1: checkbox _value is not 0 or 1 when passed as SCALAR", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
    };
    _value = [false, true] select _value;
};

_checkbox cbSetChecked _value;
