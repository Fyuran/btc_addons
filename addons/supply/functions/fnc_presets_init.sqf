#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_presets_init

Description:
    Creates and displays a presets window with saved supply configurations loaded from profile.

Parameters:
    _parent[DISPLAY]: Parent display to create the presets window on

Returns:
    NOTHING

Examples:
    (begin example)
        [_mainDisplay] call btc_supply_fnc_presets_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_parent", findDisplay 315, [displayNull]]
];
disableSerialization;

if(isNull _parent) exitWith {
	[["%1: _parent is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _display = _parent createDisplay QGVAR(RscPresets);
if(isNull _display) exitWith {
	[["%1: _display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
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
	    [["No preset is selected"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    _combo = uiNamespace getVariable[QGVAR(combo), controlNull];
    _checkbox = uiNamespace getVariable[QGVAR(checkbox), controlNull];
    _list_grp = uiNamespace getVariable[QGVAR(list_grp), controlNull];

    if(isNull _checkbox || isNull _combo || isNull _list_grp) exitWith {
	    [["Supply gui malfunctioned, one control is null: _checkbox %1, _combo: %2, _list_grp: %3", _checkbox, _combo, _list_grp], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
    if(_savedPresets isEqualTo createHashMap) exitWith {
	    [["No presets found in profileNamespace"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
    _savename = _list lbText _lbCurSel;
    _preset = _savedPresets getOrDefault[_savename, createHashMap];
    if(_preset isEqualTo createHashMap) exitWith {
	    [["No preset found in profileNamespace by %1 name", _savename], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    [_combo, _preset getOrDefault[QGVAR(table_vehicle), "B_Heli_Light_01_F"]] call FUNC(combo_load);
    [_checkbox, _preset getOrDefault[QGVAR(table_allowDamage), true]] call FUNC(checkbox_load);
    [_list_grp, _preset getOrDefault[QGVAR(table), createHashMap]] call FUNC(list_load);

    [format["Loaded preset %1", _savename]] call EFUNC(tools,3DENNotification);
    _display closeDisplay 1;
}];

private _save = _display displayCtrl PRESETS_SAVE;
_save ctrlAddEventHandler["ButtonClick", {
    params ["_save"];
    _display = ctrlParent _save;
    _edit = _display displayCtrl PRESETS_EDIT;
    _list = _display displayCtrl PRESETS_LIST;

	_allowDamageCheckbox = uiNamespace getVariable[QGVAR(checkbox), controlNull];
	_vehicleClassCombo = uiNamespace getVariable[QGVAR(combo), controlNull];

    _vehicleClass = _vehicleClassCombo lbData (lbCurSel _vehicleClassCombo);
    _allowDamage = [false, true] select (cbChecked _allowDamageCheckbox);
    
    _inventory = missionNamespace getVariable[QGVAR(table), createHashMap];
    if(_inventory isEqualTo createHashMap) exitWith {
	    [["No inventory has been set yet"], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #ifdef BTC_DEBUG_SUPPLY
        [["%1: inventory was: %2", __FILE_NAME__, _inventory], CHAT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
    };

    _savename = trim(ctrlText _edit);
    if(_savename isEqualTo "") then {
        _savename = [] call EFUNC(tools,uid);
    };

    _inner = createHashMapFromArray[
        [QGVAR(table_vehicle), _vehicleClass],
        [QGVAR(table_allowDamage), _allowDamage],
        [QGVAR(table), _inventory]
    ];
	_savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
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

    #ifdef BTC_DEBUG_SUPPLY
    [["%1: Saving preset: %2", __FILE_NAME__, _inner], CHAT, QCOMPONENT] call EFUNC(tools,debug);
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
		[["Nothing is selected", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};
	_savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
	_savedPresets deleteAt (_list lbText _lbCurSel);
	#ifdef BTC_DEBUG_SUPPLY
	[["%1: removing save: %2", __FILE_NAME__, _list lbText _lbCurSel], CHAT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
	_list lbDelete _lbCurSel;
	profileNamespace setVariable[QGVAR(savedPresets), _savedPresets];
}];
