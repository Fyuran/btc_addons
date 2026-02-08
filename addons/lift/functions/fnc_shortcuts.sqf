#include "..\script_component.hpp"
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
    Vdauphin

---------------------------------------------------------------------------- */

private _menuString = "BTC Toolchain Lift";
[
    _menuString,
    "btc_toolchain_lift_deployRopes",
    [localize "STR_ACE_Fastroping_Interaction_deployRopes", "deploy ropes from helicopter"],
    {
        if (
            !btc_lift_ropes_deployed &&
            {(driver vehicle player) isEqualTo player} &&
            {(getPosATL player) select 2 > 4}
        ) then {
            [] spawn btc_lift_fnc_deployRopes;
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
            btc_lift_ropes_deployed &&
            {(driver vehicle player) isEqualTo player}
        ) then {
            [] call btc_lift_fnc_destroyRopes;
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
        if (btc_lift_ropes_deployed) then {
            [] call btc_lift_fnc_hud;
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
        if ([] call btc_lift_fnc_check) then {
            [] spawn btc_lift_fnc_hook;
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
{}] call CBA_fnc_addKeybind;
