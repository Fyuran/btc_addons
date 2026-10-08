#include "..\..\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_behavior_attributeLoad

Description:
    Applies value to Waypoint Behavior

Parameters:
    _ctrlGrp: CONTROL - Control group
    _value: STRING - Waypoint behavior

Returns:
    NOTHING

Examples:
    (begin example)
        [_ctrlGrp, "unchanged"] call btc_toolchain_enemy_waves_fnc_behavior_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_comboGrp", controlNull, [controlNull]],
    ["_value", "", [""]]
];

if (!(_value isEqualType "")) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _value(%2):%3 not STRING", __FILE_NAME__, typeName _value, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing combo load with _value %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

disableSerialization;
private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _lbCount = lbSize _combo;
for "_i" from 0 to (_lbCount - 1) do {
    private _data = _combo lbData _i;
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: _combo curSel[%2]: %3", __FILE_NAME__, _i, _data], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif

    if (_data isEqualTo _value) exitWith {
        _combo lbSetCurSel _i;
    };
};
