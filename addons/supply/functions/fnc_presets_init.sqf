#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_presets_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_presets_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_parent", findDisplay 315, [displayNull]]
];
disableSerialization;

if(isNull _parent) exitWith {
	[["% 1: _parent is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};
private _display = _parent createDisplay QGVAR(RscPresets);
if(isNull _display) exitWith {
	[["% 1: _display is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
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
	    [["No preset is selected"], REPORT, "supply"] call EFUNC(tools,debug);
    };

    _combo = uiNamespace getVariable[QGVAR(combo), controlNull];
    _checkbox = uiNamespace getVariable[QGVAR(checkbox), controlNull];
    _list_grp = uiNamespace getVariable[QGVAR(list_grp), controlNull];

    if(isNull _checkbox || isNull _combo || isNull _list_grp) exitWith {
	    [["Supply gui malfunctioned, one control is null: _checkbox %1, _combo: %2, _list_grp: %3", _checkbox, _combo, _list_grp], REPORT, "supply"] call EFUNC(tools,debug);
    };

    _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
    if(_savedPresets isEqualTo createHashMap) exitWith {
	    [["No presets found in profileNamespace"], REPORT, "supply"] call EFUNC(tools,debug);
    };
    _savename = _list lbText _lbCurSel;
    _preset = _savedPresets getOrDefault[_savename, createHashMap];
    if(_preset isEqualTo createHashMap) exitWith {
	    [["No preset found in profileNamespace by %1 name", _savename], REPORT, "supply"] call EFUNC(tools,debug);
    };

    [_combo, _preset getOrDefault[QGVAR(table_vehicle), "B_Heli_Light_01_F"]] call FUNC(combo_load);
    [_checkbox, _preset getOrDefault[QGVAR(table_allowDamage), true]] call FUNC(checkbox_load);
    [_list_grp, _preset getOrDefault[QGVAR(table), createHashMap]] call FUNC(list_load);

    [format["Loaded preset %1", _savename]] call BIS_fnc_3DENNotification;
    _display closeDisplay 1;
}];

private _save = _display displayCtrl PRESETS_SAVE;
_save ctrlAddEventHandler["ButtonClick", {
    params ["_save"];
    _display = ctrlParent _save;
    _edit = _display displayCtrl PRESETS_EDIT;
    _list = _display displayCtrl PRESETS_LIST;

    _savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];

    _vehicleClass = missionNamespace getVariable[QGVAR(table_vehicle), "B_Heli_Light_01_F"];
    _allowDamage = missionNamespace getVariable[QGVAR(table_allowDamage), true];
    
    _inventory = missionNamespace getVariable[QGVAR(table), createHashMap];
    if(_inventory isEqualTo createHashMap) exitWith {
	    [["No inventory has been set yet"], REPORT, "supply"] call EFUNC(tools,debug);
        #ifdef BTC_DEBUG_SUPPLY
        [["% 1: inventory was: %2", __FILE_NAME__, _inventory], CHAT, "supply"] call EFUNC(tools,debug);
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
    [["% 1: Saving preset: %2", __FILE_NAME__, _inner], CHAT, "supply"] call EFUNC(tools,debug);
    #endif

    if(_savename in _savedPresets) then {
        [format["Overwriting preset %1", _savename]] call BIS_fnc_3DENNotification;
    } else {
        [format["Saving preset %1", _savename]] call BIS_fnc_3DENNotification;
    };

    profileNamespace setVariable[QGVAR(savedPresets), _savedPresets];
}];

_list ctrlAddEventHandler["LBSelChanged", {
    params ["_list", "_lbCurSel"];
    _display = ctrlParent _list;
    _edit = _display displayCtrl PRESETS_EDIT;

    _edit ctrlSetText (_list lbText _lbCurSel);
}];


private _delete = _display displayCtrl PRESETS_DELETE;
_delete ctrlAddEventHandler["ButtonClick", FUNC(presets_delete)];

_display
