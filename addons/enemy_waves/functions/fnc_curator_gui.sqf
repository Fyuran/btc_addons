#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_curator_gui

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_enemy_waves_fnc_curator_gui;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_display", displayNull, [displayNull]]
];
disableSerialization;

if(isNull _display) exitWith {
    [["%1: _display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

[{!isNull (missionNamespace getVariable[QGVAR(logic), objNull])}, {
    params[
        ["_display", displayNull, [displayNull]]
    ];
    private _logic = missionNamespace getVariable[QGVAR(logic), objNull];
    if(isNull _logic) exitWith {
        [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
    GVAR(table) = [];

    uiNamespace setVariable[QGVAR(display), _display];

	_sideComboGrp = _display displayCtrl SIDE_GROUP;
    _side_combo = _sideComboGrp controlsGroupCtrl SIDE_COMBO;
	[_side_combo] call FUNC(side_combo_init);

	_timeoutGrp = _display displayCtrl TIMEOUT_GROUP;
	_timeout = _timeoutGrp controlsGroupCtrl TIMEOUT_EDIT;
	[_timeout] call FUNC(timeout_init);

	_formationGrp = _display displayCtrl FORMATION_GROUP;
    _formation_combo = _formationGrp controlsGroupCtrl FORMATION_COMBO;
	[_formation_combo] call FUNC(formation_combo_init);


    _list_grp = _display displayCtrl MAIN_GROUP;
	[_list_grp] call FUNC(list_init);

    if(isNull _formation_combo || isNull _side_combo || isNull _timeout || isNull _list_grp) exitWith {
	    [["Enemy Waves gui malfunctioned, one control is null: _formation_combo %1, _side_combo: %2, _timeout: %3, _list_grp: %4", _formation_combo, _side_combo, _timeout, _list_grp], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    private _footerGrp = _display displayCtrl FOOTER;
    private _footerOK = _footerGrp controlsGroupCtrl FOOTER_OK;
    _footerOK ctrlAddEventHandler["ButtonClick", {
        params ["_footerOK"];
        _display = uiNamespace getVariable[QGVAR(display), displayNull];
        if(isNull _display) exitWith {};

        _logic = missionNamespace getVariable[QGVAR(logic), objNull];
        if(isNull _logic) exitWith {
            #ifdef BTC_DEBUG_ENEMY_WAVES
            [["%1: _logic of _footerOK onButtonClick is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
            #endif
        };

		if(GVAR(table) isEqualTo createHashMap) exitWith {
            ["Class table is empty", 1] call EFUNC(tools,3DENNotification);
		};

		_sideComboGrp = _display displayCtrl SIDE_GROUP;
		_side_combo = _sideComboGrp controlsGroupCtrl SIDE_COMBO;

		_timeoutGrp = _display displayCtrl TIMEOUT_GROUP;
		_timeout = _timeoutGrp controlsGroupCtrl TIMEOUT_EDIT;

		_formationGrp = _display displayCtrl FORMATION_GROUP;
		_formation_combo = _formationGrp controlsGroupCtrl FORMATION_COMBO;

		_list_grp = _display displayCtrl MAIN_GROUP;

        _clientID = [0, 2] select isMultiplayer;
        _logic setVariable[QGVAR(side), _side_combo lbValue (lbCurSel _side_combo), _clientID];
        _logic setVariable[QGVAR(timeout), parseNumber (ctrlText _timeout), _clientID];
        _logic setVariable[QGVAR(formation), _formation_combo lbText (lbCurSel _formation_combo), _clientID];
        _logic setVariable[QGVAR(list), GVAR(table), _clientID];

        _display closeDisplay 1;
        [_logic] remoteExecCall [QFUNC(spawn), _clientID];
    }];

    private _footerAbort = _footerGrp controlsGroupCtrl FOOTER_ABORT;
    _footerAbort ctrlAddEventHandler["ButtonClick", {
        params ["_footerAbort"];
        _display = uiNamespace getVariable[QGVAR(display), displayNull];
        _logic = missionNamespace getVariable[QGVAR(logic), objNull];
        deleteVehicle _logic;

        _display closeDisplay 2;
    }];
}, [_display], 10] call CBAFUNC(waitUntilAndExecute);
