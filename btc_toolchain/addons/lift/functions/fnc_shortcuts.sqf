#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_lift_fnc_shortcuts

Description:
    Registers CBA keybinds for helicopter lift operations (deploy ropes, cut ropes, toggle HUD, hook).

Parameters:
    NONE

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_lift_fnc_shortcuts;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

private _menuString = "BTC Toolchain Lift";
[
    _menuString,
    QGVAR(deployRopes),
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
    {}
] call CBAFUNC(addKeybind);

[
    _menuString,
    QGVAR(cutRopes),
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
    {}
] call CBAFUNC(addKeybind);

[
    _menuString,
    QGVAR(HUD),
    [localize "STR_BTC_TOOLCHAIN_LIFT_LDR_ACTIONHUD", "On / Off HUD"],
    {
        if (GVAR(ropes_deployed)) then {
            [] call FUNC(hud);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
    {}
] call CBAFUNC(addKeybind);


[
    _menuString,
    QGVAR(hook),
    [localize "STR_BTC_TOOLCHAIN_LIFT_HOOK", "Hook a vehicle"],
    {
        if ([] call FUNC(check)) then {
            [] spawn FUNC(hook);
            if (BTC_LIFT_PLAY_FBSOUND) then {
                playSound BTC_LIFT_FBSOUND;
            };
        };
    },
    {}
] call CBAFUNC(addKeybind);
