#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_enableDamage_onLoad

Description:
    Initializes a checkbox with enable damage on dialog load.

Parameters:
    _checkboxGrp: CONTROL - Checkbox control group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_checkboxGrp] call btc_toolchain_supply_fnc_enableDamage_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_checkboxGrp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];

private _checkbox = _checkboxGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE; 
if (isNull _checkbox) exitWith {
    [["%1: _checkbox is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable[QGVAR(enableDamage), _checkbox];

