#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_curator_okCode

Description:
    Handles confirmation button click in the curator GUI, applies configured supply settings, and triggers drop.

Parameters:
    _OKButton: CONTROL - The OK / confirm button control

Returns:
    NOTHING

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_curator_okCode;
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
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _serverId = [0, 2] select isMultiplayer;
private _editDisplay = ctrlParent _OKButton;
if (isNull _editDisplay) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _editDisplay is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _attrHash = _editDisplay getVariable [QEGVAR(gui,attributesHash), createHashMap];

private _vehicleComboGrp = _attrHash getOrDefault [QGVAR(class), controlNull];
private _vehicleCombo = _vehicleComboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
_logic setVariable [QGVAR(class), [_vehicleComboGrp] call EFUNC(gui,class_attributeSave), _serverId];

private _allowDamageGrp = _attrHash getOrDefault [QGVAR(enableDamage), controlNull];
private _allowDamageCb = _allowDamageGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
_logic setVariable[QGVAR(enableDamage), cbChecked _allowDamageCb, _serverId];

_logic setVariable [QGVAR(list_value), [GVAR(table)] call CBAFUNC(encodeJSON), _serverId];

private _debugGrp = _attrHash getOrDefault [QGVAR(debug), controlNull];
private _debugCb = _debugGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
_logic setVariable[QGVAR(debug), cbChecked _debugCb, _serverId];

_editDisplay closeDisplay 1;
[_logic] remoteExecCall [QFUNC(drop), _serverId];
