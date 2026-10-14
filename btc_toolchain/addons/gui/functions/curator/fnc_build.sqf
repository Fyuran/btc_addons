#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_build

Description:
    Performs translation from 3DEN Cfg to a Curator Gui

Display3DENEditAttributes
	ControlsBackground
		BackgroundDisable
		BackgroundDisableTiles
		Background
		BackgroundButtons
		Title
		AttributeCategories: 201
            AttributeCategory
                Controls
                Minimize
                Title
                Attributes
        ButtonOK
        ButtonCancel

AttributeCategory


Parameters:
    _moduleCfg: OBJECT or CONFIG or STRING
    _categoriesCount: NUMBER
    _okCode: CODE or STRING
    _abortCode: CODE or STRING

Returns:
    ARRAY: [_category, _attributes, _moduleInfo, _ctrlOk, _ctrlAbort]

Examples:
    (begin example)
        [this] call btc_toolchain_gui_fnc_curator_build;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
	["_moduleCfg", "", [objNull, configNull, ""]],
    ["_categoriesCount", 1, [123]],
    ["_okCode", {}, [{}, ""]],
    ["_abortCode", {}, [{}, ""]]
];
disableSerialization;

if (_categoriesCount <= 0) exitWith {
    [["%1: _categoriesCount is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (_moduleCfg isEqualType objNull) then {
    _moduleCfg = configOf _moduleCfg;
};
if (_moduleCfg isEqualType "") then {
    _moduleCfg = configFile >> "CfgVehicles" >> _moduleCfg;
};

if (!(isClass _moduleCfg)) exitWith {
    [["%1: _moduleCfg is not a valid cfg", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _moduleAttributesCfgs = configClasses [ _moduleCfg >> "Attributes", 0, false, true, false];


uiNamespace setVariable [QGVAR(sizeY), nil];
uiNamespace setVariable [QGVAR(categories), nil];

private _editDisplay = createDialog["Display3DENEditAttributes", true];
_editDisplay displayAddEventHandler ["Unload", {
    uiNamespace setVariable [QGVAR(sizeY), nil];
    uiNamespace setVariable [QGVAR(categories), nil];
}];

private _category = [_editDisplay, "=BTC= Curator Modules"] call FUNC(curator_addCategory);
private _attributes = [_editDisplay, _category, _moduleAttributesCfgs] call FUNC(curator_addAttributes);
private _minimizeEH = [_category] call FUNC(curator_addMinimizeEH);

//Title
private _editDisplayHash = [_editDisplay] call EFUNC(tools,getCtrlsHashmap);
private _ctrlTitle = _editDisplayHash getOrDefault["Title", controlNull];

private _cString = localize "$STR_3DEN_Display3DENEditAttributes_Title_text"; //as it's used internally by the engine, the escape char is '%s' which is used by printf
_cString = _cString regexReplace ["%s", getText (_moduleCfg >> "displayName")];
_ctrlTitle ctrlSetText _cString;

//ModuleInfo
private _moduleInfo = [_editDisplay, _moduleCfg] call FUNC(curator_addModuleInfo);

//Ok and Abort
private _ctrlOk = _editDisplayHash getOrDefault["ButtonOK", controlNull];
private _ctrlAbort = _editDisplayHash getOrDefault["ButtonCancel", controlNull];

_ctrlOk ctrlAddEventHandler ["ButtonClick", _okCode];
_ctrlAbort ctrlAddEventHandler ["ButtonClick", _abortCode];

[_category, _attributes, _moduleInfo, _ctrlOk, _ctrlAbort]

