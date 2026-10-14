#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_addAttributes

Description:
    Adds attributes

AttributeCategory
    Controls
        Minimize
        Title
        Attributes <--

Parameters:
    _display: DISPLAY
    _category: CONTROL
    _attributesCfgs: ARRAY

Returns:
    ARRAY of CONTROL

Examples:
    (begin example)
        [] call btc_toolchain_gui_fnc_curator_addAttributes;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_display", displayNull, [displayNull]],
    ["_category", controlNull, [controlNull]],
    ["_attributesCfgs", [], [[]]]
];

if (isNull _display) exitWith {
    [["%1: _display is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (isNull _category) exitWith {
    [["%1: _category is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _categoryHash = [_category] call EFUNC(tools,getCtrlsHashmap);
private _attributes = _categoryHash getOrDefault ["Attributes", controlNull];
if (isNull _attributes) exitWith {
    [["%1: _attributes is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _3denAttributesCfg = configFile >> "Cfg3DEN" >> "Attributes";

private _attributesCtrlsArr = [];

private _currentMaxY = uiNamespace getVariable [QGVAR(sizeY), 0]; //used for whole UI
private _currentY = 0;
_attributesCfgs apply {
    private _moduleAttributeCfg = _x;
    private _moduleAttributeCtrlClass = getText (_moduleAttributeCfg >> "control"); //class used in Cfg3DEN

    if (_moduleAttributeCtrlClass isEqualTo "ModuleInfo") then {
        continue; //will be added later by an appropriate function
    };
    private _idc = getNumber (_3denAttributesCfg >> _moduleAttributeCtrlClass >> "idc");
    if (_idc <= 0) then {
        _idc = -1;
    };
    private _attribute = _display ctrlCreate [_3denAttributesCfg >> _moduleAttributeCtrlClass, _idc, _attributes];
    _attributesCtrlsArr pushBack _attribute;

    private _tooltip = getText (_moduleAttributeCfg >> "tooltip");
    _attribute ctrlSetTooltip _tooltip;

    private _displayName = getText (_moduleAttributeCfg >> "displayName");
    private _ctrlHash = [_attribute] call EFUNC(tools,getCtrlsHashmap);
    if (_displayName isNotEqualTo "") then {
        (_ctrlHash getOrDefault ["Title", controlNull]) ctrlSetText _displayName;
    };

    //Handle listing
    private _h = (ctrlPosition _attribute) select 3;
    _attribute ctrlSetPositionY _currentY;
    _currentY = _currentY + _h;
    _attribute ctrlCommit 0;

    _currentMaxY = _currentMaxY + _h;
};

private _ctrlTitle = _categoryHash getOrDefault ["Title", controlNull];
private _titleH = if (!isNull _ctrlTitle) then {
    (ctrlPosition _ctrlTitle) select 3
} else {
    5 * (pixelH * pixelGrid * 0.50)
};

_attributes ctrlSetPositionH _currentY;
_attributes ctrlCommit 0;

_category ctrlSetPositionH (_titleH + _currentY);
_category ctrlCommit 0;

_category setVariable [QGVAR(titleHeight), _titleH];
_category setVariable [QGVAR(attributesHeight), _currentY];
_category setVariable [QGVAR(data), createHashMapFromArray [
    ["attributes", _attributes],
    ["titleH", _titleH],
    ["attributesH", _currentY]
]];

uiNamespace setVariable [QGVAR(sizeY), _currentMaxY];

_attributesCtrlsArr

