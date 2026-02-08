#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_lift_fnc_getLiftable

Description:
    Retrieves Liftable config classes

Parameters:
    _heli - [Object]

Returns:

Examples:
    (begin example)
        _result = [] call btc_lift_fnc_getLiftable;
    (end)

Author:
    Giallustio, Fyuran

---------------------------------------------------------------------------- */

params ["_heli"];

private _array = switch (typeOf _heli) do {
    case "B_SDV_01_F" : {
        ["Motorcycle", "ReammoBox", "ReammoBox_F", "StaticWeapon", "Car", "Truck", "Wheeled_APC_F", "Tracked_APC", "APC_Tracked_01_base_F", "APC_Tracked_02_base_F", "Air", "Ship", "Tank"]
    };
    default {
        private _MaxCargoMass = getNumber (configOf _heli >> "slingLoadMaxCargoMass");
        switch (true) do {
            case (_MaxCargoMass <= 510) : {
                ["Motorcycle", "ReammoBox", "ReammoBox_F", "Quadbike_01_base_F", "Strategic"];
            };
            case (_MaxCargoMass <= 2100) : {
                ["Motorcycle", "ReammoBox", "ReammoBox_F", "StaticWeapon", "Car"];
            };
            case (_MaxCargoMass <= 4100) : {
                ["Motorcycle", "ReammoBox", "ReammoBox_F", "StaticWeapon", "Car", "Truck_F", "Truck", "Wheeled_APC_F", "Air", "Ship"]
            };
            case (_MaxCargoMass <= 14000) : {
                ["Motorcycle", "ReammoBox", "ReammoBox_F", "StaticWeapon", "Car", "Truck_F", "Truck", "Wheeled_APC_F", "Tracked_APC", "APC_Tracked_01_base_F", "APC_Tracked_02_base_F", "Air", "Ship", "Tank"]
            };
            default {
                ["Motorcycle", "ReammoBox", "ReammoBox_F", "StaticWeapon", "Car", "Truck_F", "Truck", "Wheeled_APC_F", "Tracked_APC", "APC_Tracked_01_base_F", "APC_Tracked_02_base_F", "Air", "Ship", "Tank"]
            };
        };
    };
};
_array + GVAR(liftable_classes)
