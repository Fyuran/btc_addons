#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_type_attributeLoad

Description:
    Applies value to Waypoint Type CT_TREE Control

Parameters:
    _ctrlGrp: CONTROL - Control group
    _value: STRING - Waypoint config path string (default: "")

Returns:
    NOTHING

Examples:
    (begin example)
        [_ctrlGrp, "bin\config.bin/cfgWaypoints/Default/Move"] call btc_toolchain_enemy_waves_fnc_type_attributeLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrlGrp", controlNull, [controlNull]],
    ["_value", DEFAULT_CFG, []]
];

if (!(_value isEqualTypeAny ["", configNull])) then {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _value(%2):%3 not STRING or CONFIG", __FILE_NAME__, typeName _value, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    _value = DEFAULT_CFG;
};
if (_value isEqualTo "") then {
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: empty _value as STRING", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    _value = DEFAULT_CFG;
};
if (_value isEqualType "") then {
    _value = [_value] call EFUNC(tools,strToCfg);
};
if (!(isClass _value)) then {
    #ifdef BTC_DEBUG_ENEMY_WAVES
	[["%1: _value: %2 not a valid CONFIG", __FILE_NAME__, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    _value = DEFAULT_CFG;
};

private _treeCtrl = _ctrlGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_TYPE_VALUE;
if (isNull _treeCtrl) exitWith {
    [["%1: _treeCtrl is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing wp load with _value: %2", __FILE_NAME__, _value], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

//Order is never guaranteed, iterate look for path after onLoad event
private _fnc_findTreePath = {
    params ["_currentPath", "_value"];
    private _count = _treeCtrl tvCount _currentPath;
    private _found = [];

    for "_i" from 0 to (_count - 1) do {
        private _childPath = _currentPath + [_i];

        if ((_treeCtrl tvData _childPath) isEqualTo (str _value)) exitWith {
            _found = _childPath;
        };

        if (_treeCtrl tvCount _childPath > 0) then {
            private _res = [_childPath, _value] call _fnc_findTreePath;
            if (_res isNotEqualTo []) exitWith {
                _found = _res;
            };
        };
    };

    _found
};

private _path = [[], _value] call _fnc_findTreePath;

if (_path isNotEqualTo []) then {
    if (count _path > 1) then {
        for "_i" from 1 to ((count _path) - 1) do {
            _treeCtrl tvExpand (_path select [0, _i]);
        };
    };
    _treeCtrl tvSetCurSel _path;
};

#ifdef BTC_DEBUG_ENEMY_WAVES
if (_path isEqualTo []) then {
    [["%1: waypoint config '%2' not found in tree control", __FILE_NAME__, _value], REPORT, QCOMPONENT] call EFUNC(tools,debug);
} else {
    [["%1: waypoint found at path %2", __FILE_NAME__, _path], LOGS, QCOMPONENT] call EFUNC(tools,debug);
};
#endif
