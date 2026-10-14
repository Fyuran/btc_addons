#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_curator_OKCode

Description:
    Handles confirmation button click in the curator GUI, applies configured supply settings, and triggers drop.

Parameters:
    _OKButton: CONTROL - The OK / confirm button control

Returns:

Examples:
    (begin example)
        [_buttonControl] call btc_toolchain_supply_fnc_curator_OKCode;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
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

private _attributesGrp = _editDisplay displayCtrl IDC_DISPLAY3DENEDITATTRIBUTES_CATEGORIES;
if (isNull _attributesGrp) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _attributesGrp is null, available ctrls: %2", __FILE_NAME__, allControls _editDisplay], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _vehicleComboGrp = _attributesGrp controlsGroupCtrl VEHICLE_CLASS;
if (isNull _vehicleComboGrp) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _vehicleComboGrp is null, available ctrls: %2", __FILE_NAME__, allControls _editDisplay], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _vehicleCombo = _vehicleComboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
_logic setVariable[QGVAR(vehicleClass), [_vehicleComboGrp] call FUNC(combo_attributeSave), _serverId];

private _allowDamageGrp = _attributesGrp controlsGroupCtrl ALLOW_DAMAGE;
if (isNull _allowDamageGrp) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: _allowDamageGrp is null, available ctrls: %2", __FILE_NAME__, allControls _editDisplay], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};
private _allowDamageCb = _allowDamageGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
_logic setVariable[QGVAR(enableDamage), cbChecked _allowDamageCb, _serverId];

_logic setVariable [QGVAR(list_value), [GVAR(table)] call CBAFUNC(encodeJSON), _serverId];

_editDisplay closeDisplay 1;
[_logic] remoteExecCall [QFUNC(drop), _serverId];
