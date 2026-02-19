#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_curator_gui

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_curator_gui;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_display", displayNull, [displayNull]]
];
disableSerialization;

if(isNull _display) exitWith {
    [["% 1: _display is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};

private _logic = missionNamespace getVariable[QGVAR(logic), objNull];
if(isNull _logic) exitWith {};
GVAR(table) = createHashMap;

uiNamespace setVariable[QGVAR(display), _display];

private _comboGrp = _display displayCtrl CLASS;
private _combo = _comboGrp controlsGroupCtrl COMBO;
[_combo] call btc_supply_fnc_combo_init;

private _checkboxGrp = _display displayCtrl ALLOW_DAMAGE;
private _checkbox = _checkboxGrp controlsGroupCtrl CHECKBOX;
[_checkbox] call btc_supply_fnc_checkbox_init;
_checkbox cbSetChecked true;

private _list_grp = _display displayCtrl MAIN;
[_list_grp] call btc_supply_fnc_list_init;

if(isNull _checkbox || isNull _combo || isNull _list_grp) exitWith {
    [["Supply gui malfunctioned, one control is null: _checkbox %1, _combo: %2, _list_grp: %3", _checkbox, _combo, _list_grp], REPORT, "supply"] call EFUNC(tools,debug);
};
[["%1, _checkbox %2, _combo: %3, _list_grp: %4", _display, _checkbox, _combo, _list_grp], REPORT, "supply"] call EFUNC(tools,debug);

private _footerGrp = _display displayCtrl FOOTER;
private _footerOK = _footerGrp controlsGroupCtrl FOOTER_OK;
_footerOK ctrlAddEventHandler["ButtonClick", {
    params ["_footerOK"];
    _display = uiNamespace getVariable[QGVAR(display), displayNull];
    if(isNull _display) exitWith {};

    _logic = missionNamespace getVariable[QGVAR(logic), objNull];
    if(isNull _logic) exitWith {
        #ifdef BTC_DEBUG_SUPPLY
        [["% 1: _logic of _footerOK onButtonClick is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
        #endif
    };

    _comboGrp = _display displayCtrl CLASS;
    _combo = _comboGrp controlsGroupCtrl COMBO;
    _comboCurSel = lbCurSel _combo;
    if(_comboCurSel < 0) exitWith {
        [["No vehicle class selected"], REPORT, "supply"] call EFUNC(tools,debug);
    };
    _vehicleClass = _combo lbData _comboCurSel;

    _checkboxGrp = _display displayCtrl ALLOW_DAMAGE;
    _checkbox = _checkboxGrp controlsGroupCtrl CHECKBOX;

    _clientID = [0, 2] select isMultiplayer;
    _logic setVariable[QGVAR(vehicleClass), _vehicleClass, _clientID];
    _logic setVariable[QGVAR(list_value), toJSON GVAR(table), _clientID];
    _logic setVariable[QGVAR(enableDamage), cbChecked _checkbox, _clientID];

    _display closeDisplay 1;
    [_logic] remoteExecCall [QFUNC(drop), _clientID];
}];

private _footerAbort = _footerGrp controlsGroupCtrl FOOTER_ABORT;
_footerAbort ctrlAddEventHandler["ButtonClick", {
    params ["_footerAbort"];
    _display = uiNamespace getVariable[QGVAR(display), displayNull];
    _logic = missionNamespace getVariable[QGVAR(logic), objNull];
    deleteVehicle _logic;

    _display closeDisplay 2;
}];


