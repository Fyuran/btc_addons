#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_curator_okCode

Description:
    Handles confirmation button click in the curator GUI, applies configured cas settings, and triggers drop.

Parameters:
    _OKButton: CONTROL - The OK / confirm button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_cas_fnc_curator_okCode;
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
    #ifdef BTC_DEBUG_CAS
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _serverId = [0, 2] select isMultiplayer;
private _editDisplay = ctrlParent _OKButton;
if (isNull _editDisplay) exitWith {
    #ifdef BTC_DEBUG_CAS
    [["%1: _editDisplay is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _attrHash = _editDisplay getVariable [QEGVAR(gui,attributesHash), createHashMap];

private _debugGrp = _attrHash getOrDefault [QGVAR(debug), controlNull];
private _debugCb = _debugGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _allowDamageGrp = _attrHash getOrDefault [QGVAR(enableDamage), controlNull];
private _allowDamageCb = _allowDamageGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _durationGrp = _attrHash getOrDefault [QGVAR(duration), controlNull];
private _durationEdit = _durationGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _dispersionGrp = _attrHash getOrDefault [QGVAR(dispersion), controlNull];
private _dispersionEdit = _dispersionGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _distanceGrp = _attrHash getOrDefault [QGVAR(distance), controlNull];
private _distanceEdit = _distanceGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _heightGrp = _attrHash getOrDefault [QGVAR(height), controlNull];
private _heightEdit = _heightGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _triggerDisGrp = _attrHash getOrDefault [QGVAR(triggerDistance), controlNull];
private _triggerDisEdit = _triggerDisGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _remoteGrp = _attrHash getOrDefault [QGVAR(remoteControl), controlNull];
private _remoteCb = _remoteGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

private _vehicleDataGrp = _attrHash getOrDefault [QGVAR(vehicleData), controlNull];

if (cbChecked _remoteCb) then {
    private _showRemoteGrp = _attrHash getOrDefault [QGVAR(remoteHelper), controlNull];
    private _showRemoteCb = _showRemoteGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

    _logic setVariable [QGVAR(remoteControl), cbChecked _remoteCb, _serverId];
    _logic setVariable [QGVAR(remoteHelper), cbChecked _showRemoteCb, true];

    private _curatorMouseOver = curatorMouseOver;
    _curatorMouseOver params [
        ["_type", "", [""]],
        ["_object", objNull, [objNull]]
    ];
    #ifdef BTC_DEBUG_CAS
    [["%1: curatorMouseOver: %2", __FILE_NAME__, _curatorMouseOver], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif

    if ((_type isEqualTo "OBJECT") && {alive _object}) then {
        if (!isPlayer _object) then { //curatorMouseOver is never guaranteed to be hovering over player, fuck this
            private _playerIndex = allPlayers findIf {(_x distance _object )< 1};
            if (_playerIndex > -1) then {
                _object = allPlayers select _playerIndex;
            };
        };

        _logic synchronizeObjectsAdd [_object];
        _logic setVariable [QGVAR(curatorUnits), [_object], _serverId];
        #ifdef BTC_DEBUG_CAS
        [["%1: adding %2 to _logic %3", __FILE_NAME__, _object, _logic], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
    };
};

_logic setVariable [QGVAR(enableDamage), cbChecked _allowDamageCb, _serverId];
_logic setVariable [QGVAR(debug), cbChecked _debugCb, _serverId];
_logic setVariable [QGVAR(duration), parseNumber (ctrlText _durationEdit), _serverId];
_logic setVariable [QGVAR(dispersion), parseNumber (ctrlText _dispersionEdit), _serverId];
_logic setVariable [QGVAR(distance), parseNumber (ctrlText _distanceEdit), _serverId];
_logic setVariable [QGVAR(height), parseNumber (ctrlText _heightEdit), _serverId];
_logic setVariable [QGVAR(triggerDistance), parseNumber (ctrlText _triggerDisEdit), _serverId];
_logic setVariable [QGVAR(vehicleData), [_vehicleDataGrp] call FUNC(list_attributeSave), _serverId];

_editDisplay closeDisplay 1;

//allow user to rotate or move module as he sees fit
_logic hideObject false;
[{
    [_this#0] remoteExecCall [QFUNC(init), _this#1];
    (_this#0) hideObject true;
}, [_logic, _serverId], 5] call CBAFUNC(waitAndExecute);
