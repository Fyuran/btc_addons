#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_lift_fnc_shortcuts

Description:
    Create CBA keybinds for lift.

Parameters:

Returns:

Examples:
    (begin example)
        _result = [] call btc_lift_fnc_shortcuts;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

private _cfgVehicles = configFile >> "CfgVehicles";
private _allClassVehicles = ("true" configClasses _cfgVehicles) apply {configName _x};
private _allClassSorted = _allClassVehicles select {getNumber (_cfgVehicles >> _x >> "scope") isEqualTo 2};

GVAR(liftable_classes) =
flatten [  
    [
        //"Fortifications"
    ] + flatten(
        ["""A3_Structures_F_Mil_Fortification""", 
        """A3_Structures_F_Mil_BagFence""",
        """ace_logistics_wirecutter""" //wire fences
        ] apply {
        format["%1 in (configSourceAddonList _x) && {getNumber (_x >> 'scope') > 0}", _x] configClasses (configFile >> "CfgVehicles") apply {configName _x};
    }),
    [
        //"Static"
    ] + (_allClassSorted select {(
        _x isKindOf "GMG_TriPod" ||
        {_x isKindOf "StaticMortar"} ||
        {_x isKindOf "HMG_01_base_F"} ||
        {_x isKindOf "AA_01_base_F"} ||
        {_x isKindOf "AT_01_base_F"})
    }),
    [
        //"Ammobox"
        "Land_WoodenBox_F"

    ] + (_allClassSorted select {
        _x isKindOf "ReammoBox_F" &&
        {!(_x isKindOf "Slingload_01_Base_F")} &&
        {!(_x isKindOf "Pod_Heli_Transport_04_base_F")}
    }),
    [
        "Land_Cargo20_military_green_F", 
        "Land_Cargo40_military_green_F"
    ],
    [
        //"Supplies"
        "Land_Cargo20_IDAP_F"
    ],
    [
        //"FOB"
        "Land_Cargo20_blue_F"
    ],
    [
        //"Decontamination"
        "DeconShower_01_F"
    ],
    [
        //"Vehicle logistic"
        "ACE_Wheel",
        "ACE_Track",
        "B_Slingload_01_Ammo_F",
        "B_Slingload_01_Fuel_F"
    ] + (
        _allClassSorted select {_x isKindOf "FlexibleTank_base_F"}
    ),
    [
        //"Communications"
        "TFAR_Land_Communication_F"
    ],
    [
        //"Logistics supplies"
        "Land_PaperBox_closed_F"
    ]
];

private _menuString = "BTC Toolchain Lift";
[
    _menuString,
    "btc_toolchain_lift_deployRopes",
    [localize "STR_ACE_Fastroping_Interaction_deployRopes", "deploy ropes from helicopter"],
    {
        if (
            !GVAR(ropes_deployed) &&
            {(driver vehicle player) isEqualTo player} &&
            {(getPosATL player) select 2 > 4}
        ) then {
            [] spawn FUNC(deployRopes);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
{}] call CBA_fnc_addKeybind;

[
    _menuString,
    "btc_toolchain_lift_cutRopes",
    [localize "STR_ACE_Fastroping_Interaction_cutRopes", "Cut ropes from helicopter"],
    {
        if (
            GVAR(ropes_deployed) &&
            {(driver vehicle player) isEqualTo player}
        ) then {
            [] call FUNC(destroyRopes);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
{}] call CBA_fnc_addKeybind;

[
    _menuString,
    "btc_toolchain_lift_HUD",
    [localize "STR_BTC_TOOLCHAIN_LIFT_LDR_ACTIONHUD", "On / Off HUD"],
    {
        if (GVAR(ropes_deployed)) then {
            [] call FUNC(hud);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
{}] call CBA_fnc_addKeybind;


[
    _menuString,
    "btc_toolchain_lift_hook",
    [localize "STR_BTC_TOOLCHAIN_LIFT_HOOK", "Hook a vehicle"],
    {
        if ([] call FUNC(check)) then {
            [] spawn FUNC(hook);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
{}] call CBA_fnc_addKeybind;
