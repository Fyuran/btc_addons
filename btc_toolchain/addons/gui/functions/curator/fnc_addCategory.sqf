#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_addCategory

Description:
    Adds a category

AttributeCategories: 201
    AttributeCategory <---

Parameters:
    _display: DISPLAY - Display to add category to
    _categoryTitle: STRING - Title text for the category
    _categoryCfg: CONFIG or STRING - Category config entry (optional, default: Display3DENEditAttributes >> AttributeCategory)
    _padding: NUMBER - Category padding value (optional, default: CATEGORY_PADDING)

Returns:
    CONTROL
    
Examples:
    (begin example)
        [_display, "My Category"] call btc_toolchain_gui_fnc_curator_addCategory;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params[
    ["_display", displayNull, [displayNull]],
    ["_categoryTitle", "", [""]],
    ["_categoryCfg", configFile >> "Display3DENEditAttributes" >> "AttributeCategory", [configNull, ""]],
    ["_padding", CATEGORY_PADDING, [123]]
];

if (isNull _display) exitWith {
    [["%1: _display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    createHashMap
};

private _attributeCategories = _display displayCtrl IDC_DISPLAY3DENEDITATTRIBUTES_CATEGORIES;
if (isNull _attributeCategories) exitWith {
    [["%1: _attributeCategories is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    createHashMap
};


private _category = _display ctrlCreate [_categoryCfg, -1, _attributeCategories];
private _categoryHash = [_category] call EFUNC(tools,getCtrlsHashmap);

private _ctrlTitle = _categoryHash getOrDefault ["Title", controlNull];
_ctrlTitle ctrlSetText _categoryTitle;

private _currentMaxY = uiNamespace getVariable [QGVAR(sizeY), 0];
if (_currentMaxY > 0) then {
    _currentMaxY = _currentMaxY + _padding;
};

private _h = if (!isNull _ctrlTitle) then {
    (ctrlPosition _ctrlTitle) select 3
} else {
    (ctrlPosition _category) select 3
};

_category ctrlSetPositionY _currentMaxY;
_category ctrlSetPositionH _h;
_category ctrlCommit 0;

_currentMaxY = _currentMaxY + _h;
uiNamespace setVariable [QGVAR(sizeY), _currentMaxY];

_attributeCategories setVariable [QGVAR(padding), _padding];

private _categories = _attributeCategories getVariable [QGVAR(categories), []];
_categories pushBack _category;
_attributeCategories setVariable [QGVAR(categories), _categories];

private _uiCategories = uiNamespace getVariable [QGVAR(categories), []];
_uiCategories pushBack _category;
uiNamespace setVariable [QGVAR(categories), _uiCategories];

//[_categoryCtrlGrp] call EFUNC(tools,getCtrlsHashmap);
_category

