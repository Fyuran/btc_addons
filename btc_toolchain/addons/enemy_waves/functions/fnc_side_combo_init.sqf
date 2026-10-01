#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_side_combo_init

Description:
    Initializes the side selection combo control in UI namespace with default side.

Parameters:
    _combo: CONTROL

Returns:

Examples:
    (begin example)
        [_sideCombo] call btc_toolchain_enemy_waves_fnc_side_combo_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrl", controlNull, [controlNull, []], [1, 2]]
];
private _ctrlGroup = if (_ctrl isEqualType []) then {_ctrl select 0} else {_ctrl};
private _combo = if (ctrlIDC _ctrlGroup isEqualTo SIDE_COMBO) then {
    _ctrlGroup
} else {
    _ctrlGroup controlsGroupCtrl SIDE_COMBO
};
disableSerialization;
#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing combo init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
uiNamespace setVariable[QGVAR(side_combo), _combo];

[_combo, 0] call FUNC(side_combo_load);
