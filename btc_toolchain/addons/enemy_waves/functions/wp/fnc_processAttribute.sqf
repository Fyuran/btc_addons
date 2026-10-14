#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_wp_processAttribute

Description:
    Due to the discrepancy of BIS when dealing with GUI SpeedModeWaypoint, BehaviorWaypoint and so on...
    where every fucking thing is lower cased and has underscores, the only solution is this pathetic function.

Parameters:
    _wpAttribute: STRING, NUMBER or ARRAY - Waypoint attribute value to process

Returns:
    Upper cased and invalid chars removed string

Examples:
    (begin example)
        ["stag_column"] call btc_toolchain_enemy_waves_fnc_wp_processAttribute;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_wpAttribute", "", [123, "", []]]
]; 

//non string attributes are returned as is
if (!(_wpAttribute isEqualType "")) exitWith {
    _wpAttribute
};

if (_wpAttribute isEqualTo "") exitWith {""};

private _fixedString = toUpper (_wpAttribute regexReplace["_", " "]);

_fixedString
