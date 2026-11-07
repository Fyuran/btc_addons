#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_list_1onLBSelChanged

Description:
    Handles onLBSelChanged of LIST_1 (weapons). Populates LIST_2 (fire modes)
    for the selected weapon and selects index 0.

Parameters:
    _grp1List: CONTROL - LIST_1 listbox control
    _lbCurSel: NUMBER - Selected index

Returns:
    NOTHING

Examples:
    (begin example)
        [_grp1List, 0] call btc_toolchain_cas_fnc_list_1onLBSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_grp1List", controlNull, [controlNull]],
    ["_lbCurSel", -1, [123]]
];

if (_lbCurSel < 0) exitWith {};

private _wpnClass = _grp1List lbData _lbCurSel;
if (_wpnClass isEqualTo "") exitWith {
    [["%1: _wpnClass is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_CAS
[["%1: executing list_1onLBSelChanged: Ctrl: %2 - lbCurSel: %3 - _grp1List lbData: %4", __FILE_NAME__, _grp1List, _lbCurSel, _wpnClass], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _modes = [_wpnClass] call EFUNC(tools,getWeaponModes);

private _grp1ListGrp = ctrlParentControlsGroup _grp1List;
private _vehicleDataGrp = ctrlParentControlsGroup _grp1ListGrp;
private _grp2ListGrp = _vehicleDataGrp controlsGroupCtrl LIST_2;
private _grp2List = _grp2ListGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

lbClear _grp2List;
_modes apply {
    private _row = _grp2List lbAdd _x;
    _grp2List lbSetData [_row, _x];
};

if (lbSize _grp2List > 0) then {
    _grp2List lbSetCurSel 0;
};
