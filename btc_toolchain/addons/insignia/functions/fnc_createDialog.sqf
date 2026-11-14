#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_insignia_fnc_createDialog

Description:
    Creates the insignia selection dialog display.

Parameters:
    _parentDisplay: DISPLAY (defaults to findDisplay 46)

Returns:
    DISPLAY

Examples:
    (begin example)
        [] call btc_toolchain_insignia_fnc_createDialog;
    (end)

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params [
    ["_parentDisplay", findDisplay 46, [displayNull]]
];

private _display = createDialog [QGVAR(gui), true];
if (isNull _display) exitWith {
    #ifdef BTC_DEBUG_INSIGNIA
	[["%1: insignia display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    [] call FUNC(destroyCamera);

    displayNull
};
uiNamespace setVariable [QGVAR(display), _display];
_display displayAddEventHandler["Unload", {
    params ["_display", "_exitCode"];
    uiNamespace setVariable [QGVAR(display), nil];
}];

private _group1 = _display displayCtrl GROUP_1_IDC;
private _list = _group1 controlsGroupCtrl LIST_IDC;
private _picture = _group1 controlsGroupCtrl PICTURE_IDC;

//No Insignia Entry
private _row = _list lbAdd "None";

//All entries
private _configs = "true" configClasses (configFile >> "CfgUnitInsignia");
_configs apply {
    private _cfg = _x;
    private _displayName = getText (_cfg >> "displayName");
    private _texture = getText (_cfg >> "texture");

    private _row = _list lbAdd _displayName;
    _list lbSetPicture [_row, _texture];
    _list lbSetData [_row, configName _cfg];
};

_list ctrlAddEventHandler ["LBSelChanged", {
    params [
        ["_list", controlNull, [controlNull]], 
        ["_lbCurSel", -1, [123]]
    ];

    private _group1 = ctrlParentControlsGroup _list;
    private _picture = _group1 controlsGroupCtrl PICTURE_IDC;

    private _curPicture = _list lbPicture _lbCurSel;
    private _curClassName = _list lbData _lbCurSel;
    _picture ctrlSetText _curPicture;

    [player, _curClassName] call BIS_fnc_setUnitInsignia;
}];

private _ehKeyDown = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key isNotEqualTo DIK_ESCAPE) exitWith { false };

    private _cam = uiNamespace getVariable [QGVAR(camera), objNull];
    [_cam] call FUNC(destroyCamera);
    _display closeDisplay IDC_OK;

    true
}];

_display
