#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_getClassInfo

Description:
    Returns the display name, icon/picture, and config type for a given class.

Parameters:
    _class: STRING - Class name to query

Returns:
    ARRAY - [_displayName, _icon, _type]

Examples:
    (begin example)
        ["B_Soldier_F"] call btc_toolchain_gui_fnc_getClassInfo;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_class", "", [""]]
];

switch (true) do {
    case (isClass (configFile >> "CfgVehicles" >> _class)): {
        private _icon = getText (configFile >> "CfgVehicles" >> _class >> "icon");
        if (!fileExists _icon) then { //icon sometimes refers to a .paa file and sometimes to a property name in CfgVehicleIcons
            _icon = getText (configFile >> "CfgVehicleIcons" >> _icon);
        };
        [
            getText (configFile >> "CfgVehicles" >> _class >> "displayName"),
            _icon,
            "CfgVehicles"
        ]
    };
    case (isClass (configFile >> "CfgWeapons" >> _class)): {
        [
            getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
            getText (configFile >> "CfgWeapons" >> _class >> "picture"),
            "CfgWeapons"
        ]
    };
    case (isClass (configFile >> "CfgMagazines" >> _class)): {
        [
            getText (configFile >> "CfgMagazines" >> _class >> "displayName"),
            getText (configFile >> "CfgMagazines" >> _class >> "picture"),
            "CfgMagazines"
        ]
    };
    case (isClass (configFile >> "CfgGlasses" >> _class)): {
        [
            getText (configFile >> "CfgGlasses" >> _class >> "displayName"),
            getText (configFile >> "CfgGlasses" >> _class >> "picture"),
            "CfgGlasses"
        ]
    };
    default {
        [
            "",
            "",
            ""
        ]
    };
};
