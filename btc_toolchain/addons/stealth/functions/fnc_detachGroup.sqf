#include "..\script_component.hpp"
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
