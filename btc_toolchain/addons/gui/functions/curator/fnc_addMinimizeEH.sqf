#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_addMinimizeEH

Description:
    Adds minimize functionalities

AttributeCategories: 201
    AttributeCategory
        Controls
            Minimize
            Title
            Attributes

Parameters:
    _category: CONTROL

Returns:
    
Examples:
    (begin example)
        [] call btc_toolchain_gui_fnc_curator_addMinimizeEH;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_category", controlNull, [controlNull]]
];

private _categoryHash = [_category] call EFUNC(tools,getCtrlsHashmap);
private _ctrlMinimize = _categoryHash getOrDefault ["Minimize", controlNull];
if (isNull _ctrlMinimize) exitWith {
    #ifdef BTC_DEBUG_GUI
    [["%1: _ctrlMinimize is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    -1
};

_ctrlMinimize cbSetChecked true; //default it to open
_ctrlMinimize ctrlAddEventHandler ["CheckedChanged", {
    params ["_control", "_checked"];

    private _category = ctrlParentControlsGroup _control;
    if (isNull _category) then {
        _category = ctrlParent _control;
    };

    private _data = _category getVariable [QGVAR(data), createHashMap];
    private _attributes = _data getOrDefault ["attributes", controlNull];
    if (isNull _attributes) then {
        private _categoryHash = [_category] call EFUNC(tools,getCtrlsHashmap);
        _attributes = _categoryHash getOrDefault ["Attributes", controlNull];
    };

    private _titleH = _data getOrDefault [
        "titleH",
        _category getVariable [QGVAR(titleHeight), 5 * (pixelH * pixelGrid * 0.50)]
    ];
    private _attributesH = _data getOrDefault [
        "attributesH",
        _category getVariable [QGVAR(attributesHeight), 0]
    ];

    private _isExpanded = _checked isNotEqualTo 0 && {_checked isNotEqualTo false};

    // 1. Show or hide attributes
    _attributes ctrlShow _isExpanded;

    // 2. Adjust category height
    private _newH = if (_isExpanded) then { _titleH + _attributesH } else { _titleH };
    _category ctrlSetPositionH _newH;
    _category ctrlCommit 0;

    // 3. Re-flow all categories in the container upwards/downwards
    private _attributeCategories = ctrlParentControlsGroup _category;
    private _categories = if (!isNull _attributeCategories) then {
        _attributeCategories getVariable [QGVAR(categories), []]
    } else {
        uiNamespace getVariable [QGVAR(categories), []]
    };
    private _padding = if (!isNull _attributeCategories) then {
        _attributeCategories getVariable [QGVAR(padding), CATEGORY_PADDING]
    } else {
        CATEGORY_PADDING
    };

    private _currentY = 0;
    _categories apply {
        if (_currentY > 0) then {
            _currentY = _currentY + _padding;
        };
        _x ctrlSetPositionY _currentY;
        _x ctrlCommit 0;
        _currentY = _currentY + ((ctrlPosition _x) select 3);
    };

    uiNamespace setVariable [QGVAR(sizeY), _currentY];
}];

