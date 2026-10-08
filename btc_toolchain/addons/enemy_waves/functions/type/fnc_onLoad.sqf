#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_type_onLoad

Description:
    Initializes WP Type list on dialog load.

Parameters:
    _ctrlGrp: CONTROL - The control group

Returns:
    NOTHING

Examples:
    (begin example)
        [_this] call btc_toolchain_enemy_waves_fnc_type_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_ctrlGrp", controlNull, [controlNull, []], [1, 2]]
];

private _treeCtrl = _ctrlGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_TYPE_VALUE;
if (isNull _treeCtrl) exitWith {
    [["%1: _treeCtrl is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _root = configFile >> "cfgWaypoints";
private _categories = configClasses [_root, 0, false, false]; //configClasses [config, depth, includeInherited, allSubclasses, classNames]
 
_categories apply {
    private _parentCfg = _x;
    private _parentIndex = _treeCtrl tvAdd [[], getText (_parentCfg >> "displayName")];

    private _children = configClasses [_parentCfg, 0, false, false];
    _children apply {
        private _childCfg = _x;
        private _childIndex = _treeCtrl tvAdd [[_parentIndex], getText (_childCfg >> "displayName")];
        _treeCtrl tvSetPicture [[_parentIndex, _childIndex], getText (_childCfg >> "icon")];

        _treeCtrl tvSetData [[_parentIndex, _childIndex], str _childCfg];
    };
};

