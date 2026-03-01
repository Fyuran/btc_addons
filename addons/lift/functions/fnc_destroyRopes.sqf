#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_lift_fnc_destroyRopes

Description:
    Destroys ropes

Parameters:
    _heli - [Object]

Returns:

Examples:
    (begin example)
        _result = [] call btc_toolchain_lift_fnc_destroyRopes;
    (end)

Author:
    Giallustio, Fyuran

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
