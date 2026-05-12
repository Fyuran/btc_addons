#include "..\script_component.hpp"

params[
    ["_group", grpNull, [grpNull]],
    ["_threat", 0, [123]],
    ["_varName", "threat", [""]] //horrible hack to add to body threat
];
if(isGamePaused) exitWith {0};
if(isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};
if(!local _group) exitWith {
	[["%1: _group is not local", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};

private _limit = _group getVariable[QGVAR(threat_limit), 4];
private _debug = (_group getVariable[QGVAR(logic), objNull]) getVariable[QGVAR(debug), false];

_threat = (_threat max 0) min _limit; //clamp value
_group setVariable[format[QGVAR(%1), _varName], _threat, _debug];

_threat
