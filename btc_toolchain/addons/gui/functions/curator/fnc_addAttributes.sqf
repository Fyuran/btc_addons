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
    ARRAY

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
private _attributesHash = _display getVariable [QGVAR(attributesHash), createHashMap];

private _currentMaxY = uiNamespace getVariable [QGVAR(sizeY), 0]; //used for whole UI
private _currentY = 0;
_attributesCfgs apply {
    private _moduleAttributeCfg = _x;
    private _moduleAttributeCtrlClass = getText (_moduleAttributeCfg >> "control"); //class used in Cfg3DEN

    if (_moduleAttributeCtrlClass isEqualTo "ModuleInfo") then {
        continue; //will be added later by an appropriate function
    };
    private _attributeCfg = _3denAttributesCfg >> _moduleAttributeCtrlClass;
    private _idc = getNumber (_attributeCfg >> "idc");
    if (_idc <= 0) then {
        _idc = -1;
    };
    private _attribute = _display ctrlCreate [_attributeCfg, _idc, _attributes];
    _attributesCtrlsArr pushBack _attribute;

    private _property = getText (_moduleAttributeCfg >> "property");
    if (_property isEqualTo "") then {
        _property = configName _moduleAttributeCfg;
    };
    _attributesHash set [_property, _attribute];
    _attributesHash set [configName _moduleAttributeCfg, _attribute];
    _attribute setVariable [QGVAR(config), _moduleAttributeCfg];
    _attribute setVariable [QGVAR(property), _property];

    private _tooltip = getText (_moduleAttributeCfg >> "tooltip");
    _attribute ctrlSetTooltip _tooltip;

    private _displayName = getText (_moduleAttributeCfg >> "displayName");
    private _ctrlHash = [_attribute] call EFUNC(tools,getCtrlsHashmap);
    if (_displayName isNotEqualTo "") then {
        (_ctrlHash getOrDefault ["Title", controlNull]) ctrlSetText _displayName;
    };

    // Look up the module property's defaultValue
    private _defaultValueCfg = _moduleAttributeCfg >> "defaultValue";
    if (!isNumber _defaultValueCfg && {!isText _defaultValueCfg}) then {
        _defaultValueCfg = _attributeCfg >> "defaultValue";
    };

    private _defaultValue = if (isNumber _defaultValueCfg) then {
        getNumber _defaultValueCfg
    } else {
        if (isText _defaultValueCfg) then {
            private _defaultText = getText _defaultValueCfg;
            private _compiled = call compile _defaultText;
            if (isNil "_compiled") then {
                _defaultText
            } else {
                _compiled
            };
        } else {
            nil
        };
    };

    // Coerce type based on typeName if specified
    private _typeName = toUpper getText (_moduleAttributeCfg >> "typeName");
    if (!isNil "_defaultValue") then {
        switch (_typeName) do {
            case "BOOL": {
                if (_defaultValue isEqualType 0) then {
                    _defaultValue = _defaultValue > 0;
                } else {
                    if (_defaultValue isEqualType "") then {
                        _defaultValue = (toLower _defaultValue) in ["true", "1"];
                    };
                };
            };
            case "NUMBER": {
                if (_defaultValue isEqualType "") then {
                    _defaultValue = parseNumber _defaultValue;
                };
            };
            case "STRING": {
                if !(_defaultValue isEqualType "") then {
                    _defaultValue = str _defaultValue;
                };
            };
        };
    };

    // Look up attributeLoad expression from module attribute config (or fallback to attribute control config)
    private _attributeLoad = getText (_moduleAttributeCfg >> "attributeLoad");
    if (_attributeLoad isEqualTo "") then {
        _attributeLoad = getText (_attributeCfg >> "attributeLoad");
    };

    if (_attributeLoad isNotEqualTo "" && {!isNil "_defaultValue"}) then {
        private _config = _attributeCfg;
        private _value = _defaultValue;
        _attribute call (compile _attributeLoad);
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
    5 * h_PIXELH
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

_display setVariable [QGVAR(attributesHash), _attributesHash];
uiNamespace setVariable [QGVAR(attributesHash), _attributesHash];

_attributesCtrlsArr
