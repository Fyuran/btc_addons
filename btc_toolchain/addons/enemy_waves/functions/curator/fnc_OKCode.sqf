#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_curator_OKCode

Description:
    Handles confirmation button click in the curator GUI, applies configured wave settings, and triggers spawn.

Parameters:
    _OKButton: CONTROL - The OK / confirm button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_enemy_waves_fnc_curator_OKCode;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_OKButton", controlNull, [controlNull]]
];
disableSerialization;

private _logic = missionNamespace getVariable[QGVAR(logic), objNull];
if (isNull _logic) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _serverId = [0, 2] select isMultiplayer;
private _editDisplay = ctrlParent _OKButton;
if (isNull _editDisplay) exitWith {
    #ifdef BTC_DEBUG_ENEMY_WAVES
    [["%1: _editDisplay is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if (GVAR(table) isEqualTo createHashMap) exitWith {
    ["Class table is empty", 1] call EFUNC(tools,3DENNotification);
};

private _sideComboGrp = _editDisplay displayCtrl SIDE_GRP;
private _side_combo = _sideComboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _timeoutGrp = _editDisplay displayCtrl TIMEOUT;
private _timeout = _timeoutGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _formationGrp = _editDisplay displayCtrl FORMATION_WP;
private _formationToolboxCtrl = _formationGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
private _formation = ['no change','wedge','vee','line','column','file','stag_column','ech_left','ech_right','diamond'] select (_formationToolboxCtrl lbValue (lbCurSel _formationToolboxCtrl));

private _seekCbGrp = _editDisplay displayCtrl SEEK_END;
private _seek_cb= _seekCbGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _clientID = [0, 2] select isMultiplayer;
_logic setVariable [QGVAR(side), _side_combo lbValue (lbCurSel _side_combo), _clientID];
_logic setVariable [QGVAR(timeout), parseNumber (ctrlText _timeout), _clientID];
_logic setVariable [QGVAR(seek_end), cbChecked _seek_cb, _clientID];
_logic setVariable [QGVAR(formation), _formation, _clientID];
_logic setVariable [QGVAR(list_value), GVAR(table), _clientID];

_editDisplay closeDisplay 1;
[_logic] remoteExecCall [QFUNC(spawn_begin), _clientID];
