#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_side_combo_attributeLoad

Description:
    Populates the side combo control with faction options (OPFOR, BLUFOR, INDEPENDENT, CIVILIAN) and sets current selection.

Parameters:
    _combo: CONTROL or ARRAY - Side combo control or control array
    _value: NUMBER or STRING - Selected side index

Returns:

Examples:
    (begin example)
        [_sideCombo, 0] call btc_toolchain_enemy_waves_fnc_side_combo_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_comboGrp", controlNull, [controlNull]],
    ["_value", 0, [123, ""]]
];
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing combo load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if(_value isEqualType "") then {
	_value = parseNumber _value;
};

private _lbCount = lbSize _combo;
for "_i" from 0 to (_lbCount - 1) do {
    if ((_combo lbValue _i) isEqualTo _value) exitWith {
        _combo lbSetCurSel _i;
    };
};
