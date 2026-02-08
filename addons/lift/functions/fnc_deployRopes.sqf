#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_lift_fnc_deployRopes

Description:
    Deploys ropes

Parameters:
    _heli - [Object]

Returns:

Examples:
    (begin example)
        _result = [] call btc_lift_fnc_deployRopes;
    (end)

Author:
    Giallustio, Fyuran

---------------------------------------------------------------------------- */

params [
    ["_heli", vehicle player, [objNull]]
];

GVAR(ropes_deployed) = true;
GVAR(lifted) = false;
GVAR(hud) = false;

_heli setVariable ["cargo", nil];

ropeCreate [_heli, "slingload0", 10, []];

GVAR(action_hud) = player addAction [
    "<t color=""#ED2744"">" + (localize "STR_BTC_TOOLCHAIN_LIFT_LDR_ACTIONHUD") + "</t>", // Hud On\Off
    FUNC(hud), [], -8, false, false, "", QGVAR(ropes_deployed)
];
GVAR(action_hook) = player addAction [
    "<t color=""#ED2744"">" + (localize "STR_BTC_TOOLCHAIN_LIFT_HOOK") + "</t>", // Hook
    {[] call FUNC(hook)}, [], 9, true, false, "", QUOTE([] call FUNC(check))
];

waitUntil {sleep 5; (vehicle player isEqualTo player)};

GVAR(ropes_deployed) = false;
player removeAction GVAR(action_hook);
player removeAction GVAR(action_hud);

if (ropes _heli isNotEqualTo []) then {
    {ropeDestroy _x;} forEach ropes _heli;
};
