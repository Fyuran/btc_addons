#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_list_init

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_list_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_main_grp", controlNull, [controlNull]]
];
disableSerialization;

#ifdef BTC_DEBUG_SUPPLY_DIALOG
[["% 1: executing attribute init", __FILE_NAME__], CHAT, "supply"] call EFUNC(tools,debug);
#endif
GVAR(table) = createHashMap;
uiNamespace setVariable[QGVAR(list_grp), _main_grp];

//Group 1
private _grp1 = _main_grp controlsGroupCtrl GROUP_1;
if((ctrlIDC _grp1) isNotEqualTo GROUP_1) exitWith {
	[["% 1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp1, GROUP_1], REPORT, "supply"] call EFUNC(tools,debug);
};
private _grp1_edit = _grp1 controlsGroupCtrl EDIT_1;
private _grp1_add = _grp1 controlsGroupCtrl ADD_1;
private _grp1_remove = _grp1 controlsGroupCtrl REMOVE_1;
private _grp1_list = _grp1 controlsGroupCtrl LIST_1;

/*
    ADD_1 adds new item if cfg is valid then update/init the HashMap with new a new entry and default values
*/
_grp1_add ctrlAddEventHandler ["ButtonClick", {
    params ["_add"];

    _grp1 = ctrlParentControlsGroup _add;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;
    _edit = _grp1 controlsGroupCtrl EDIT_1;
    
    _class = trim(ctrlText _edit);
    _cfg = configFile >> "CfgVehicles" >> _class;
    if(!isClass _cfg) exitWith {
        [format["%1 invalid ammo box or vehicle class", _class], 1] call BIS_fnc_3DENNotification;
    };

    _row = _grp1_list lbAdd (getText (_cfg >> "displayName"));
    _grp1_list lbSetCurSel _row;
    //_grp1_list lbSetPicture [_row, getText (_cfg >> "icon")];

    _uid = format["%1-%2", _class, ([] call EFUNC(tools,uid))];
    _grp1_list lbSetData [_row, _uid];

    //table inits
    _inner = GVAR(table) getOrDefault [_uid, createHashMap, true];
    _inner set ["class", _class];
    _inner set ["inventory", createHashMap];
}];

/*
    REMOVE_1 removes everything from HashMap corresponding to UID in lbCurSel of LIST_1's data and clear LIST_2 by proxy
*/
_grp1_remove ctrlAddEventHandler ["ButtonClick", {
    params ["_remove"];

    _grp1 = ctrlParentControlsGroup _remove;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

    _lbCurSel = lbCurSel _grp1_list;
    if(_lbCurSel < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call BIS_fnc_3DENNotification;
    };

    _uid = _grp1_list lbData (lbCurSel _grp1_list);
    GVAR(table) deleteAt _uid;

    _grp1_list lbDelete _lbCurSel;
    _grp1_list lbSetCurSel -1; //Should trigger LBSelChanged -1 exitWith lbClear
}];

/*
    LIST_1 LBSelChanged gets all the saved items of the HashMap corresponding to the UID saved in lbCurSel of LIST_1's data
    then it should parse all items from cfg if valid and display them in LIST_2
*/
_grp1_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_grp1_list", "_lbCurSel"];

    _grp1 = ctrlParentControlsGroup _grp1_list;
    _main = ctrlParentControlsGroup _grp1;
    _grp2 = _main controlsGroupCtrl GROUP_2;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;

    if(_lbCurSel < 0) exitWith {
        lnbClear _grp2_list;
    };

    //retrieve LIST_1 lbCurSel's data from the HashMap
    _uid = _grp1_list lbData _lbCurSel;
    _inventory = (GVAR(table) get _uid) get "inventory";

    lnbClear _grp2_list;
    _inventory apply {
        [_x, _y] params [
            ["_class", "", [""]],
            ["_amount", 0, [123]]
        ];
        private _lnbNewRow = switch (true) do {
            case (isClass (configFile >> "CfgVehicles" >> _class)): {
                [
                    getText (configFile >> "CfgVehicles" >> _class >> "displayName"),
                    getText (configFile >> "CfgVehicles" >> _class >> "icon"),
                    _amount
                ]
            };
            case (isClass (configFile >> "CfgWeapons" >> _class)): {
                [
                    getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
                    getText (configFile >> "CfgWeapons" >> _class >> "picture"),
                    _amount
                ]
            };
            case (isClass (configFile >> "CfgMagazines" >> _class)): {
                [
                    getText (configFile >> "CfgMagazines" >> _class >> "displayName"),
                    getText (configFile >> "CfgMagazines" >> _class >> "picture"),
                    _amount
                ]
            };
            default {
                [
                    "REPORT",
                    "REPORT",
                    -1
                ]
            };
        };

        _lnbNewRow params [
            ["_displayName", "UNKNOWN", [""]], 
            ["_icon", "", [""]],
            ["_amount", 0, [123]]
        ];
        if(_displayName isEqualTo "REPORT") exitWith {
            [format["%1 invalid vehicle, weapon or magazine class", _class], 1] call BIS_fnc_3DENNotification;
        };

        private _row = _grp2_list lnbAddRow [_displayName, str _amount];
        _grp2_list lnbSetData [[_row, 0], _class];
        _grp2_list lnbSetPicture [[_row, 0], _icon];
    };
}];

/*
    copyToClipboard is restricted to server
    0x2E = C key, Copy to clipboard selected object's class from LIST_1 lbCurSel
*/
if(isServer) then {
    _grp1_list ctrlAddEventHandler["KeyDown", {
        params ["_grp1_list", "_key", "_shift", "_ctrl", "_alt"];
        if(_key isEqualTo 0x2E && {_ctrl}) then {
            //retrieve LIST_1 lbCurSel's data from the HashMap
            _uid = _grp1_list lbData (lbCurSel _grp1_list);
            _class = (GVAR(table) get _uid) get "class";
            [format["%1 class saved into clipboard", _class]] call BIS_fnc_3DENNotification;
            copyToClipboard _class;
            false
        };
    }];
};

//Group 2
private _grp2 = _main_grp controlsGroupCtrl GROUP_2;
if((ctrlIDC _grp2) isNotEqualTo GROUP_2) exitWith {
	[["% 1: invalid idc: %2 should be %3", __FILE_NAME__, ctrlIDC _grp2, GROUP_2], REPORT, "supply"] call EFUNC(tools,debug);
};
private _grp2_edit = _grp2 controlsGroupCtrl EDIT_2;
private _grp2_add = _grp2 controlsGroupCtrl ADD_2;
private _grp2_remove = _grp2 controlsGroupCtrl REMOVE_2;
private _grp2_list = _grp2 controlsGroupCtrl LIST_2;
private _grp2_list2_buttonLeft = _grp2 controlsGroupCtrl ARROWLEFT;
private _grp2_list2_buttonRight = _grp2 controlsGroupCtrl ARROWRIGHT;
/*
    Add_2 adds new inventory class to LIST_2 if it's valid then update the HashMap 
    of lbCurSel of LIST_1's data uid with new inventory class and default value
*/
_grp2_add ctrlAddEventHandler ["ButtonClick", {
    params ["_add"];

    _grp2 = ctrlParentControlsGroup _add;
    _edit = _grp2 controlsGroupCtrl EDIT_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

    if((lbCurSel _grp1_list) < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call BIS_fnc_3DENNotification;
    };

    _class = trim(ctrlText _edit);
    //Update HashMap
    _uid = _grp1_list lbData (lbCurSel _grp1_list);
    _inventory = (GVAR(table) get _uid) get "inventory";
    if(_class in _inventory) exitWith {
        [format["%1 already exists inside this object's inventory", _class], 1] call BIS_fnc_3DENNotification;
    };
    
    private _lnbNewRow = switch (true) do {
        case (isClass (configFile >> "CfgWeapons" >> _class)): {
            [
                getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
                getText (configFile >> "CfgWeapons" >> _class >> "picture"),
                 1
            ]
        };
        case (isClass (configFile >> "CfgMagazines" >> _class)): {
            [
                getText (configFile >> "CfgMagazines" >> _class >> "displayName"),
                getText (configFile >> "CfgMagazines" >> _class >> "picture"),
                1
            ]
        };
        default {
            [
                "REPORT",
                "REPORT",
                -1
            ]
        };
    };
    _lnbNewRow params [
        ["_displayName", "UNKNOWN", [""]], 
        ["_icon", "", [""]],
        ["_amount", 0, [123]]

    ];
    if(_displayName isEqualTo "REPORT") exitWith {
        [format["%1 invalid inventory class", _class], 1] call BIS_fnc_3DENNotification;
    };
    _inventory set [_class, 1];

    //Add new entry
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    private _row = _grp2_list lnbAddRow [_displayName, str _amount];
    _grp2_list lnbSetData [[_row, 0], _class];
    _grp2_list lnbSetPicture [[_row, 0], _icon];
    _grp2_list lnbSetCurSelRow _row;

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

    _grp2_list_lnbCurSelRow = lnbCurSelRow _grp2_list;
    if((lbCurSel _grp1_list) < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call BIS_fnc_3DENNotification;
    };
    if(_grp2_list_lnbCurSelRow < 0) exitWith {
        ["Nothing is selected in Supplies List", 1] call BIS_fnc_3DENNotification;
    };

    //Update HashMap
    _uid = _grp1_list lbData (lbCurSel _grp1_list);
    _inventory = (GVAR(table) get _uid) get "inventory";
    _class = _grp2_list lnbData [_grp2_list_lnbCurSelRow, 0];
    _inventory deleteAt _class;

    _grp2_list lnbDeleteRow _grp2_list_lnbCurSelRow;
    _grp2_list lnbSetCurSelRow -1;
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
            [format["%1 class saved into clipboard", _class]] call BIS_fnc_3DENNotification;
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

    _grp2_list_lnbCurSelRow = lnbCurSelRow _grp2_list;
    if((lbCurSel _grp1_list) < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call BIS_fnc_3DENNotification;
    };
    if(_grp2_list_lnbCurSelRow < 0) exitWith {
        ["Nothing is selected in Supplies List", 1] call BIS_fnc_3DENNotification;
    };


    //Update HashMap
    _uid = _grp1_list lbData (lbCurSel _grp1_list);
    _inventory = (GVAR(table) get _uid) get "inventory";
    _class = _grp2_list lnbData [_grp2_list_lnbCurSelRow, 0];
    _amount = _inventory get _class;
    _inventory set [_class, (_amount - 1) max 1];

    //Update UI
    _grp2_list lnbSetText [[_grp2_list_lnbCurSelRow, 1], str ((_amount - 1) max 1)];
}];
_grp2_list2_buttonRight ctrlAddEventHandler ["ButtonClick", {
    params ["_btn"];

    _grp2 = ctrlParentControlsGroup _btn;
    _grp2_list = _grp2 controlsGroupCtrl LIST_2;
    _main = ctrlParentControlsGroup _grp2;
    _grp1 = _main controlsGroupCtrl GROUP_1;
    _grp1_list = _grp1 controlsGroupCtrl LIST_1;

    _grp2_list_lnbCurSelRow = lnbCurSelRow _grp2_list;
    if((lbCurSel _grp1_list) < 0) exitWith {
        ["Nothing is selected in Objects List", 1] call BIS_fnc_3DENNotification;
    };
    if(_grp2_list_lnbCurSelRow < 0) exitWith {
        ["Nothing is selected in Supplies List", 1] call BIS_fnc_3DENNotification;
    };


    //Update HashMap
    _uid = _grp1_list lbData (lbCurSel _grp1_list);
    _inventory = (GVAR(table) get _uid) get "inventory";
    _class = _grp2_list lnbData [_grp2_list_lnbCurSelRow, 0];
    _amount = _inventory get _class;
    _inventory set [_class, _amount + 1];

    //Update UI
    _grp2_list lnbSetText [[_grp2_list_lnbCurSelRow, 1], str (_amount + 1)];
}];

/* #ifdef BTC_DEBUG_SUPPLY_DIALOG
if(missionNamespace getVariable[QGVAR(debug_init), false]) exitWith {}; //Test Load if it works
//Row 0
_grp1_list lbAdd getText(configFile >> "CfgVehicles" >> "Land_CargoBox_V1_F" >> "displayName");
private _uid = "Land_CargoBox_V1_F" + ([] call EFUNC(tools,uid));
_grp1_list lbSetData[0, _uid];
private _inner = GVAR(table) getOrDefault [_uid, createHashMap, true];
_inner set ["class", "Land_CargoBox_V1_F"];
_inner set ["inventory", createHashMap];
private _inventory = (GVAR(table) get _uid) get "inventory";
_inventory set ["30Rnd_556x45_Stanag", 2];
_inventory set ["30Rnd_556x45_Stanag_green", 10];

//Row 1
_grp1_list lbAdd getText(configFile >> "CfgVehicles" >> "Land_CargoBox_V1_F" >> "displayName");
private _uid = "Land_CargoBox_V1_F" + ([] call EFUNC(tools,uid));
_grp1_list lbSetData[1, _uid];
private _inner = GVAR(table) getOrDefault [_uid, createHashMap, true];
_inner set ["class", "Land_CargoBox_V1_F"];
_inner set ["inventory", createHashMap];
private _inventory = (GVAR(table) get _uid) get "inventory";
_inventory set ["30Rnd_556x45_Stanag", 4];

GVAR(debug_init) = true;
#endif */
