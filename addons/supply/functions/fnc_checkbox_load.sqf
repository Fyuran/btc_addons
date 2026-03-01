#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_checkbox_load

Description:
    Sets the checked state of a checkbox control from a boolean or scalar value.

Parameters:
    _checkbox[CONTROL]: Checkbox control to update
    _value[BOOLEAN or SCALAR]: Checked state (boolean or 0/1 as scalar)

Returns:
    NOTHING

Examples:
    (begin example)
        [_damageCheckbox, true] call btc_supply_fnc_checkbox_load;
        [_damageCheckbox, 1] call btc_supply_fnc_checkbox_load;
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
[["%1: executing checkbox load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if(_value isEqualType 123) then {
    if(_value > 1) exitWith {
        [["%1: checkbox _value is not 0 or 1 when passed as SCALAR", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
    _value = [false, true] select _value;
};

_checkbox cbSetChecked _value;
