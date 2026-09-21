#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_detachGroup

Description:
    Detaches a single unit from its current group into a new independent single-unit group, preserving original waypoints.

Parameters:
    _unit: OBJECT

Returns:
    GROUP

Examples:
    (begin example)
        [_unit] call btc_toolchain_stealth_fnc_detachGroup;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_unit", objNull, [objNull]]
];

private _originalGroup = group _unit;
private _wps = [_originalGroup] call FUNC(getWaypoints);

private _side = (getNumber(configOf _unit >> "side")) call BIS_fnc_sideType;
private _group = createGroup [_side, true];
private _groups = missionNamespace getVariable[QGVAR(groups), []];
_groups pushBack _group;
missionNamespace setVariable[QGVAR(groups), _groups];

[_unit] joinSilent _group;
[_group, _wps] call FUNC(setWaypoints);

_group
