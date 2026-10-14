#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_manual_triggers_fnc_canShow

Description:
    Performs checks to see if we can show the action

Parameters:

Returns:
    BOOLEAN if can show action

Examples:
    (begin example)
        [] call btc_toolchain_manual_triggers_fnc_canShow;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

(([] call BIS_fnc_admin) > 0) || 
{isServer} || 
{player getVariable [QGVAR(isSpecialBoy), false]} || 
{!isNull (getAssignedCuratorLogic player)}
