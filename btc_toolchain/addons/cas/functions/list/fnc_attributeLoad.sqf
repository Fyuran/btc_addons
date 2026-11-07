#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_list_attributeLoad

Description:
    Restores saved weapon and fire mode indices into LIST_1 and LIST_2 controls.

Parameters:
    _main_grp: CONTROL - Main vehicleData controls group
    _value: ARRAY OR STRING - Saved indices [weaponIndex, modeIndex]

Returns:
    NOTHING

Examples:
    (begin example)
        [_vehicleDataGrp, [0, 0]] call btc_toolchain_cas_fnc_list_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_main_grp", controlNull, [controlNull]],
    ["_value", createHashMap, []]
];
disableSerialization;

if (!(_value isEqualTypeAny ["", createHashMap])) exitWith {
    #ifdef BTC_DEBUG_CAS
	[["%1: _value(%2):%3 not STRING or HASHMAP", __FILE_NAME__, typeName _value, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};
disableSerialization;

#ifdef BTC_DEBUG_CAS
[["%1: executing list load with _value: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

if (_value isEqualTo "") exitWith {
    #ifdef BTC_DEBUG_CAS
    [["%1: empty _value as STRING", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
if (_value isEqualTo createHashMap) exitWith {
    #ifdef BTC_DEBUG_CAS
    [["%1: empty _value as HASHMAP", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
if (_value isEqualType "") then {
    GVAR(table) = fromJSON _value;
} else {
    GVAR(table) = +_value;
};
if (GVAR(table) isEqualTo createHashMap) exitWith { //check again after parsing
	#ifdef BTC_DEBUG_CAS
	[["%1: GVAR(table) is an empty hashmap", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
};

//get controls refs
private _classGrp = _main_grp controlsGroupCtrl VEHICLE_CLASS;
private _grp1ListGrp = _main_grp controlsGroupCtrl LIST_1;

private _classCombo = _classGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
private _grp1List = _grp1ListGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

if (isNull _classCombo || isNull _grp1List) exitWith {
    [["%1: null ctrls found: %2, %3", __FILE_NAME__, _classCombo, _grp1List], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//retrieve data from _value
private _class = GVAR(table) getOrDefault ["class", ""];
if (_class isEqualTo "") exitWith {
    #ifdef BTC_DEBUG_CAS
    [["%1: empty _class", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _listData = GVAR(table) getOrDefault ["listData", []];

private _classItemCount = lbSize _classCombo;
for "_i" from 0 to (_classItemCount - 1) do {
    if ((_classCombo lbData _i) isEqualTo _class) exitWith {
        _classCombo lbSetCurSel _i;
    };
};

private _list1ItemCount = lbSize _grp1List;
for "_i" from 0 to (_list1ItemCount - 1) do {
    private _lbData = _grp1List lbData _i;
    private _dataIndex = _listData findIf {_x isEqualTo _lbData};
    if (_dataIndex != -1) then {
        _grp1List lbSetSelected [_i, true];
    };
};
