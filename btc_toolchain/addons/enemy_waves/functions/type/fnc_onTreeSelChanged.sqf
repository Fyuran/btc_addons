#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_type_onTreeSelChanged

Description:
    Handles Tree onTreeSelChanged

Parameters:
    _treeCtrl: CONTROL - The Tree control
    _selectionPath: ARRAY - Tree selection path

Returns:
    NOTHING

Examples:
    (begin example)
        [_treeCtrl, []] call btc_toolchain_enemy_waves_fnc_type_onTreeSelChanged;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_treeCtrl", controlNull, [controlNull]],
    ["_selectionPath", [], [[]]]
];

//File EditBox filling
private _wp_cfg = _treeCtrl tvData _selectionPath;
if (_wp_cfg isEqualTo "") exitWith {};

_wp_cfg = [_wp_cfg] call EFUNC(tools,strToCfg);

private _script = "";
if (!(isNull _wp_cfg) && {isClass _wp_cfg}) then {
    _script = getText (_wp_cfg >> "file");
};

[_treeCtrl, _script] spawn { //forced to wait until UI is done being constructed
    params["_treeCtrl", "_script"];
    private _treeGrp = ctrlParentControlsGroup _treeCtrl;
    private _attributesGrp = ctrlParentControlsGroup _treeGrp;

    waitUntil {!(isNull (_attributesGrp controlsGroupCtrl FILE))};
    private _fileGrp = _attributesGrp controlsGroupCtrl FILE;

    waitUntil {!(isNull (_fileGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE))};
    private _fileCtrl = _fileGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;

    _fileCtrl ctrlSetText _script;
};
