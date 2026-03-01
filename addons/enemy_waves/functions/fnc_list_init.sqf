#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_enemy_waves_fnc_list_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]]
];
disableSerialization;

#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
[["%1: executing list init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
GVAR(table) = [];
uiNamespace setVariable[QGVAR(list_grp), _main_grp];

//Group 1
private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
if((ctrlIDC _grp1) isNotEqualTo GROUP_1) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp1, GROUP_1], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _grp1_add = _grp1 controlsGroupCtrl ADD_1;
private _grp1_remove = _grp1 controlsGroupCtrl REMOVE_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

/*
    ADD_1 adds new group then update/init the HashMap with new a new entry and default values
*/
_grp1_add ctrlAddEventHandler ["ButtonClick", {
    params ["_add"];

    _grp1 = ctrlParentControlsGroup _add;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;
	

    //row inits
	_groupsCount = count GVAR(table); //new item
    GVAR(table) pushBack [];

    _row = _grp1_list lbAdd (format["Group %1", _groupsCount + 1]);
    _grp1_list lbSetCurSel _row;

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: adding new row: Group %2", __FILE_NAME__, _groupsCount + 1], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];

/*
    REMOVE_1 removes everything from HashMap corresponding to UID in lbCurSel of LIST_1's data and clear LIST_2 by proxy EH
*/
_grp1_remove ctrlAddEventHandler ["ButtonClick", {
    params ["_remove"];

    _grp1 = ctrlParentControlsGroup _remove;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

    _groupIndex = lbCurSel _grp1_list;
    if(_groupIndex < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call EFUNC(tools,3DENNotification);
    };
    GVAR(table) deleteAt _groupIndex;
	[ctrlParentControlsGroup _grp1, GVAR(table)] call btc_toolchain_enemy_waves_fnc_list_load;
    _grp1_list lbSetCurSel -1; //Triggers LBSelChanged exitWith lbClear

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: removing _row %2 with Group %3", __FILE_NAME__, _groupIndex, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];

/*
    LIST_1 LBSelChanged gets all the saved items of the HashMap corresponding to the UID saved in lbCurSel of LIST_1's data
    then it should parse all items from cfg if valid and display them in LIST_2
*/
_grp1_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_grp1_list", "_groupIndex"];

    _grp1 = ctrlParentControlsGroup _grp1_list;
    _main = ctrlParentControlsGroup _grp1;
    _grp2 = _main controlsGroupCtrl GROUP_2;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    lnbClear _grp2_list;

    if(_groupIndex < 0) exitWith {};
    _groupClasses = GVAR(table) select _groupIndex;

	if(_groupClasses isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
		[["%1: LIST_1 LBSelChanged's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		#endif
	};

    _groupClasses apply {
        _x params [
            ["_class", "", [""]],
            ["_amount", 1, [123]]
        ];
		_classCfg = configFile >> "CfgVehicles" >> _class;
		_manCfg = configFile >> "CfgVehicles" >> "CAManBase";
		_landCfg = configFile >> "CfgVehicles" >> "Land";
		_inherits = ([_classCfg, _manCfg] call CBAFUNC(inheritsFrom)) || ([_classCfg, _landCfg] call CBAFUNC(inheritsFrom));
		if(!_inherits) then {
            [format["%1 class is not of type 'Land' or 'CAManBase'", _class], 1] call EFUNC(tools,3DENNotification);
			continue;
		};
        private _lnbNewRow = [
			getText (_classCfg >> "displayName"),
			getText (_classCfg >> "icon"),
			_amount
		];

        _lnbNewRow params [
            ["_displayName", "UNKNOWN", [""]], 
            ["_icon", "", [""]],
            ["_amount", 1, [123]]
        ];

        private _row = _grp2_list lnbAddRow [_displayName, str _amount];
        _grp2_list lnbSetData [[_row, 0], _class];
        _grp2_list lnbSetPicture [[_row, 0], format["\a3\ui_f\data\map\vehicleicons\%1_ca.paa", _icon]];
    };
	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: filling LIST_2 with %2", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];

//Group 2
private _grp2 = _main_grp controlsGroupCtrl GROUP_2;
if((ctrlIDC _grp2) isNotEqualTo GROUP_2) exitWith {
	[["%1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp2, GROUP_2], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _grp2_edit = _grp2 controlsGroupCtrl EDIT_2;
private _grp2_add = _grp2 controlsGroupCtrl ADD_2;
private _grp2_remove = _grp2 controlsGroupCtrl REMOVE_2;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _grp2_list2_buttonLeft = _grp2 controlsGroupCtrl ARROWLEFT;
private _grp2_list2_buttonRight = _grp2 controlsGroupCtrl ARROWRIGHT;
/*
    Add_2 adds new enemy class to LIST_2 if it's valid then update the HashMap 
    of lbCurSel of LIST_1's data uid with new class and default value
*/
_grp2_add ctrlAddEventHandler ["ButtonClick", {
    params ["_add"];

    _grp2 = ctrlParentControlsGroup _add;
	_grp2_list = _grp2 controlsGroupCtrl LIST_2;
    _edit = _grp2 controlsGroupCtrl EDIT_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;
	_groupIndex = lbCurSel _grp1_list;

	//Update UI
    if(_groupIndex < 0) exitWith {
        ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
	};
    _groupClasses = GVAR(table) select _groupIndex;

    _class = trim(ctrlText _edit);
	if(_class isEqualTo "") exitWith {
		["Empty class passed", 1] call EFUNC(tools,3DENNotification);
	};

	_classExists = (_groupClasses findIf {
		_x params["_c", "_amount"];
		_c isEqualTo _class;
	}) isNotEqualTo -1;
	if(_classExists) exitWith {
		[format["%1 class already exists", _class], 1] call EFUNC(tools,3DENNotification);
	};

	_classCfg = configFile >> "CfgVehicles" >> _class;
	_manCfg = configFile >> "CfgVehicles" >> "CAManBase";
	_landCfg = configFile >> "CfgVehicles" >> "Land";
	_inherits = ([_classCfg, _manCfg] call CBAFUNC(inheritsFrom)) || ([_classCfg, _landCfg] call CBAFUNC(inheritsFrom));
	if(!_inherits) exitWith {
		[format["%1 class is not of type 'Land' or 'CAManBase'", _class], 1] call EFUNC(tools,3DENNotification);
	};

	_sideCombo = uiNamespace getVariable[QGVAR(side_combo), controlNull];
	_selectedSide = (_sideCombo lbValue (lbCurSel _sideCombo)) call BIS_fnc_sideType;
	_classFaction = (getNumber(configFile >> "CfgFactionClasses" >> (getText(_classCfg >> "faction")) >> "side")) call BIS_fnc_sideType;

	if(_selectedSide isNotEqualTo _classFaction) exitWith {
		[format["%1's faction(%2) does not belong to %3", _class, str _classFaction, str _selectedSide], 1] call EFUNC(tools,3DENNotification);
	};

	private _lnbNewRow = [
		getText (_classCfg >> "displayName"),
		getText (_classCfg >> "icon"),
		1
	];

	_lnbNewRow params [
		["_displayName", "UNKNOWN", [""]], 
		["_icon", "", [""]],
		["_amount", 1, [123]]
	];

	private _row = _grp2_list lnbAddRow [_displayName, str _amount];
	_grp2_list lnbSetData [[_row, 0], _class];
	_grp2_list lnbSetPicture [[_row, 0], format["\a3\ui_f\data\map\vehicleicons\%1_ca.paa", _icon]];
	_grp2_list lnbSetCurSelRow _row;

    //Update HashMap
    _groupClasses pushBack [_class, 1];

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: Adding %2 to Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];

/*
    Remove from LIST_2 the entry and remove from the HashMap everything corresponding to LIST_2 lbCurSel class stored in its data
*/
_grp2_remove ctrlAddEventHandler ["ButtonClick", {
    params ["_remove"];

    _grp2 = ctrlParentControlsGroup _remove;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

    _enemyClassIndex = lnbCurSelRow _grp2_list;
    if((lbCurSel _grp1_list) < 0) exitWith {
        ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
    };
    if(_enemyClassIndex < 0) exitWith {
        ["Nothing is selected in Enemy Classes List", 1] call EFUNC(tools,3DENNotification);
    };

    //Update HashMap
    _groupIndex = lbCurSel _grp1_list;
	if(_groupIndex < 0) exitWith {
        ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
	};
    _groupClasses = GVAR(table) select _groupIndex;
	if(_groupClasses isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
		[["%1: LIST_2 REMOVE's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		#endif
	};

    _class = _groupClasses deleteAt _enemyClassIndex;
    _grp2_list lnbDeleteRow _enemyClassIndex;
    _grp2_list lnbSetCurSelRow -1;

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: Removing %2 from Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];

/*
    copyToClipboard is restricted to server
    0x2E = C key, Copy to clipboard selected object's class from LIST_2 lnbCurSelRow
*/
if(isServer) then {
    _grp2_list ctrlAddEventHandler["KeyDown", {
        params ["_grp2_list", "_key", "_shift", "_ctrl", "_alt"];
        if(_key isEqualTo 0x2E && {_ctrl}) then {
            //retrieve LIST_1 lbCurSel's data from the HashMap
            _class = _grp2_list lnbData[(lnbCurSelRow _grp2_list), 0];
            [format["%1 class saved into clipboard", _class]] call EFUNC(tools,3DENNotification);
            copyToClipboard _class;
            false
        };
    }];
};

/*
    LIST_2 idcLeft and idcRight add or remove one unit from LIST_2 lnbCurSelRow column 1 and update the HashMap accordingly
*/
_grp2_list2_buttonLeft ctrlAddEventHandler ["ButtonClick", {
    params ["_btn"];

    _grp2 = ctrlParentControlsGroup _btn;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

	_groupIndex = lbCurSel _grp1_list;
    if(_groupIndex < 0) exitWith {
        ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
	};

    _enemyClassIndex = lnbCurSelRow _grp2_list;
    if(_enemyClassIndex < 0) exitWith {
        ["Nothing is selected in Enemy Classes List", 1] call EFUNC(tools,3DENNotification);
    };

    //Update HashMap
	_groupClasses = GVAR(table) select _groupIndex;
	if(_groupClasses isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
		[["%1: LIST_2 buttonLeft's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		#endif
	};
    _group = _groupClasses select _enemyClassIndex;
	_group params ["_class", "_amount"];
    _group set [1, (_amount - 1) max 1];

    //Update UI
    _grp2_list lnbSetText [[_enemyClassIndex, 1], str ((_amount - 1) max 1)];

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: Removing 1 of %2 from Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];
_grp2_list2_buttonRight ctrlAddEventHandler ["ButtonClick", {
    params ["_btn"];

    _grp2 = ctrlParentControlsGroup _btn;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

	_groupIndex = lbCurSel _grp1_list;
    if(_groupIndex < 0) exitWith {
        ["Nothing is selected in Groups List", 1] call EFUNC(tools,3DENNotification);
	};

    _enemyClassIndex = lnbCurSelRow _grp2_list;
    if(_enemyClassIndex < 0) exitWith {
        ["Nothing is selected in Enemy Classes List", 1] call EFUNC(tools,3DENNotification);
    };

    //Update HashMap
	_groupClasses = GVAR(table) select _groupIndex;
	if(_groupClasses isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
		[["%1: LIST_2 buttonLeft's _groupClasses is empty", __FILE_NAME__, _groupClasses], LOGS, QCOMPONENT] call EFUNC(tools,debug);
		#endif
	};
    _group = _groupClasses select _enemyClassIndex;
	_group params ["_class", "_amount"];
    _group set [1, _amount + 1];

    //Update UI
    _grp2_list lnbSetText [[_enemyClassIndex, 1], str (_amount + 1)];

	#ifdef BTC_DEBUG_ENEMY_WAVES_DIALOG
	[["%1: Adding 1 of %2 to Group %3", __FILE_NAME__, _class, _groupIndex], LOGS, QCOMPONENT] call EFUNC(tools,debug);
	#endif
}];
