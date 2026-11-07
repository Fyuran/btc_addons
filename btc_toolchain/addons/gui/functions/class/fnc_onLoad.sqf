#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_class_onLoad

Description:
    Initializes a combo box with available classes from config and stores reference in uiNamespace on dialog load.

Parameters:
    _comboGrp: CONTROL - Combo box control group to populate
    _baseClass: STRING - Base class to filter subclasses (optional, default: "All")
    _predicate: CODE - Predicate to filter list of configs, passed arg is _config
    _setDefaultSel: BOOLEAN - If should set combo to default 0

Returns:
    NOTHING

Examples:
    (begin example)
        [_comboGrp, "Air"] call btc_toolchain_gui_fnc_class_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_comboGrp", controlNull, [controlNull]],
    ["_baseClass", "All", [""]],
    ["_predicate", {true}, [{}]],
    ["_setDefaultSel", true, [false]]
];
disableSerialization;
#ifdef BTC_DEBUG_GUI
[["%1: executing class onLoad", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _combo = _comboGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
if (isNull _combo) exitWith {
    [["%1: _combo is null, _this = %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

uiNamespace setVariable [QGVAR(class), _combo];
lbClear _combo;

private _configs = [_baseClass] call EFUNC(tools,getAllConfigsOf);
_configs apply {
    if (!([_x] call _predicate)) then {
        continue;
    };
    private _row = _combo lbAdd (getText (_x >> "displayName"));
    _combo lbSetPicture [_row, getText (_x >> "icon")];
    _combo lbSetData [_row, configName _x];
    _combo lbSetTooltip [_row, configName _x];

    private _faction = getText (_x >> "faction");
    if (_faction isNotEqualTo "") then {
        private _flagPath = getText (configFile >> "CfgFactionClasses" >> _faction >> "flag");
        _combo lbSetPictureRight [_row, _flagPath];
    };
};

lbSort _combo;
if (_setDefaultSel) then {
    _combo lbSetCurSel 0;
};
