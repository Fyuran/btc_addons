#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_class_onLBSelChanged

Description:
    Handles onLBSelChanged of vehicle class combo box. Populates LIST_1 (weapons)
    and cascades selection to LIST_2 (fire modes).

Parameters:
    _combo: CONTROL - Combo box control
    _lbCurSel: NUMBER - Current selected index

Returns:
    NOTHING

Examples:
    (begin example)
        [_combo, 0] call btc_toolchain_cas_fnc_class_onLBSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_combo", controlNull, [controlNull]],
    ["_lbCurSel", -1, [123]]
];

if (_lbCurSel < 0) exitWith {};

#ifdef BTC_DEBUG_CAS
[["%1: executing class onLBSelChanged: Ctrl: %2 - lbCurSel: %3", __FILE_NAME__, _combo, _lbCurSel], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _class = _combo lbData _lbCurSel;
if (_class isEqualTo "") exitWith {};

[_class] call FUNC(list_initVehicleData);
