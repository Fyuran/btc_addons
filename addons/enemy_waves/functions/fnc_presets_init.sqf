#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_enemy_waves_fnc_presets_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_enemy_waves_fnc_presets_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_parent", findDisplay 315, [displayNull]]
];
disableSerialization;

if(isNull _parent) exitWith {
	[["%1: _parent is null", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
};
private _display = _parent createDisplay QEGVAR(supply,RscPresets);
if(isNull _display) exitWith {
	[["%1: _display is null", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
};

private _list = _display displayCtrl PRESETS_LIST;
private _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
if(_savedPresets isNotEqualTo createHashMap) then {
    _savedPresets apply {
        [_x, _y] params [
            "_savename",
            "_inner"
        ];
        _row = _list lbAdd _savename;
        _list lbSetData[_row, toJSON _inner];
    };
};

private _load = _display displayCtrl PRESETS_LOAD;
_load ctrlAddEventHandler["ButtonClick", {
    params ["_load"];
    _display = ctrlParent _load;

    _list = _display displayCtrl PRESETS_LIST;
    _lbCurSel = lbCurSel _list;
    if(_lbCurSel < 0) exitWith {
	    [["No preset is selected"], REPORT, "enemy_waves"] call EFUNC(tools,debug);
    };

    _side_combo = uiNamespace getVariable[QGVAR(side_combo), controlNull];
	_timeout = uiNamespace getVariable[QGVAR(timeout), controlNull];
    _formation_combo = uiNamespace getVariable[QGVAR(formation_combo), controlNull];
    _list_grp = uiNamespace getVariable[QGVAR(list_grp), controlNull];

    if(isNull _formation_combo || isNull _side_combo || isNull _timeout || isNull _list_grp) exitWith {
	    [["Enemy Waves gui malfunctioned, one control is null: _formation_combo %1, _side_combo: %2, _timeout: %3, _list_grp: %4", _formation_combo, _side_combo, _timeout, _list_grp], REPORT, "enemy_waves"] call EFUNC(tools,debug);
    };

    _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
    if(_savedPresets isEqualTo createHashMap) exitWith {
	    [["No presets found in profileNamespace"], REPORT, "enemy_waves"] call EFUNC(tools,debug);
    };
    _savename = _list lbText _lbCurSel;
    _preset = _savedPresets getOrDefault[_savename, createHashMap];
    if(_preset isEqualTo createHashMap) exitWith {
	    [["No preset found in profileNamespace by %1 name", _savename], REPORT, "enemy_waves"] call EFUNC(tools,debug);
    };

    [_side_combo, _preset getOrDefault[QGVAR(side), east]] call FUNC(side_combo_load);
    [_timeout, _preset getOrDefault[QGVAR(timeout), 60]] call FUNC(timeout_load);
    [_formation_combo, _preset getOrDefault[QGVAR(formation), "COLUMN"]] call FUNC(formation_combo_load);
    [_list_grp, _preset getOrDefault[QGVAR(table), []]] call FUNC(list_load);

    [format["Loaded preset %1", _savename]] call EFUNC(tools,3DENNotification);
    _display closeDisplay 1;
}];

private _save = _display displayCtrl PRESETS_SAVE;
_save ctrlAddEventHandler["ButtonClick", {
    params ["_save"];
    _display = ctrlParent _save;
    _edit = _display displayCtrl PRESETS_EDIT;
    _list = _display displayCtrl PRESETS_LIST;

    _side_combo = uiNamespace getVariable[QGVAR(side_combo), controlNull];
	_timeout = uiNamespace getVariable[QGVAR(timeout), controlNull];
    _formation_combo = uiNamespace getVariable[QGVAR(formation_combo), controlNull];

    _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];

    _side = _side_combo lbValue (lbCurSel _side_combo);
    _timeout = parseNumber (ctrlText _timeout);
    _formation = _formation_combo lbText (lbCurSel _formation_combo);

    _classes = missionNamespace getVariable[QGVAR(table), createHashMap];
    if(_classes isEqualTo createHashMap) exitWith {
	    [["No inventory has been set yet"], REPORT, "enemy_waves"] call EFUNC(tools,debug);
        #ifdef BTC_ENEMY_WAVES_DEBUG
        [["%1: inventory was: %2", __FILE_NAME__, _classes], CHAT, "enemy_waves"] call EFUNC(tools,debug);
        #endif
    };

    _savename = trim(ctrlText _edit);
    if(_savename isEqualTo "") then {
        _savename = [] call EFUNC(tools,uid);
    };

    _inner = createHashMapFromArray[
        [QGVAR(side), _side],
        [QGVAR(timeout), _timeout],
        [QGVAR(formation), _formation],
        [QGVAR(table), _classes]
    ];
	if(_savename in _savedPresets) then {
        [format["Overwriting preset %1", _savename]] call EFUNC(tools,3DENNotification);
    } else {
        [format["Saving preset %1", _savename]] call EFUNC(tools,3DENNotification);
    };
    _savedPresets set [_savename, _inner];

    //List refresh, as there is no way to iterate a list items just clear it and rebuild it, just so we avoid duplicates as keys are unique
    lbClear _list;
    _savedPresets apply {
        [_x, _y] params [
            "_savename",
            "_inner"
        ];
        _row = _list lbAdd _savename;
        _list lbSetData[_row, toJSON _inner];
    };

    #ifdef BTC_ENEMY_WAVES_DEBUG
    [["%1: Saving preset: %2", __FILE_NAME__, _inner], CHAT, "enemy_waves"] call EFUNC(tools,debug);
    #endif

    profileNamespace setVariable[QGVAR(savedPresets), _savedPresets];
}];

_list ctrlAddEventHandler["LBSelChanged", {
    params ["_list", "_lbCurSel"];
    _display = ctrlParent _list;
    _edit = _display displayCtrl PRESETS_EDIT;

    _edit ctrlSetText (_list lbText _lbCurSel);
}];


private _delete = _display displayCtrl PRESETS_DELETE;
_delete ctrlAddEventHandler["ButtonClick", {
	params ["_delete"];
	private _display = ctrlParent _delete;
	private _list = _display displayCtrl PRESETS_LIST;
	private _lbCurSel = lbCurSel _list;
	if(_lbCurSel < 0) exitWith {
		[["Nothing is selected", __FILE_NAME__], REPORT, "enemy_waves"] call EFUNC(tools,debug);
	};
	_savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
	_savedPresets deleteAt (_list lbText _lbCurSel);
	#ifdef BTC_ENEMY_WAVES_DEBUG
	[["%1: removing save: %2", __FILE_NAME__, _list lbText _lbCurSel], CHAT, "enemy_waves"] call EFUNC(tools,debug);
	#endif
	_list lbDelete _lbCurSel;
	profileNamespace setVariable[QGVAR(savedPresets), _savedPresets];
}];
