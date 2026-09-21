#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_lift_fnc_destroyRopes

Description:
    Cuts and destroys deployed sling load ropes from the helicopter and resets lift state.

Parameters:
    _heli: OBJECT

Returns:

Examples:
    (begin example)
        [vehicle player] call btc_toolchain_lift_fnc_destroyRopes;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_heli", vehicle player, [objNull]]
];

GVAR(ropes_deployed) = false;
GVAR(hud) = false;
GVAR(lifted) = false;

player removeAction GVAR(action_hook);
player removeAction GVAR(action_hud);

if (ropes _heli isNotEqualTo []) then {
    {
        ropeDestroy _x;
    } forEach ropes _heli;
};

_heli setVariable ["cargo", nil];
