#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_addModuleInfo

Description:
    Adds Module Information box to the bottom of the stack

Parameters:
    _display: DISPLAY
    _moduleCfg: CONFIG

Returns:
    CONTROL
    
Examples:
    (begin example)
        [] call btc_toolchain_gui_fnc_curator_addModuleInfo;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_display", displayNull, [displayNull]],
	["_moduleCfg", configNull, [configNull]]
];

if (isNull _display) exitWith {
    [["%1: _display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (isNull _moduleCfg) exitWith {
    [["%1: _moduleCfg is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _moduleDescription = getText (_moduleCfg >> "ModuleDescription" >> "description");
private _moduleInfo = [_display, "", configFile >> "Cfg3DEN" >> "Attributes" >> "ModuleInfo"] call FUNC(curator_addCategory);

private _moduleInfoHash = [_moduleInfo] call EFUNC(tools,getCtrlsHashmap);
private _ctrlText = _moduleInfoHash getOrDefault ["Text", controlNull];
_ctrlText ctrlSetText _moduleDescription;

_ctrlText

