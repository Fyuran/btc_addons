#include "..\script_component.hpp"

params[
    ["_group", grpNull, [grpNull]],
    ["_amount", 0, [123]],
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

private _threat = _group getVariable[format[QGVAR(%1), _varName], 0];
private _limit = _group getVariable[QGVAR(threat_limit), 4];
_amount = (_amount * TICK_RATE) * accTime;
_threat = ((_threat + _amount) max 0) min _limit; //clamp value

private _debug = (_group getVariable[QGVAR(logic), objNull]) getVariable[QGVAR(debug), false];
_group setVariable[format[QGVAR(%1), _varName], _threat, _debug];

_threat
