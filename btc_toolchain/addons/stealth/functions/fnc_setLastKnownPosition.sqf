#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_setLastKnownPosition

Description:
    Sets and records the last known enemy position on an AI group with an optional randomized radius offset.

Parameters:
    _group: GROUP/OBJECT/LOCATION
    _pos: ARRAY/OBJECT/GROUP
    _radius: NUMBER

Returns:
    ARRAY

Examples:
    (begin example)
        [_group, getPos player, 10] call btc_toolchain_stealth_fnc_setLastKnownPosition;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_group", objNull, [objNull, grpNull, locationNull]],
    ["_pos", [0, 0, 0], [[], objNull, grpNull]],
    ["_radius", 0, [123]]
];
if(isNull _group) exitWith {
	[["%1: _group is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!local _group) exitWith {
	[["%1: _group is not local", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};
if(_pos isEqualType objNull) then {
    _pos = ASLToAGL (eyePos _pos);
};
if(_pos isEqualType grpNull) then {
    _pos = ASLToAGL (eyePos (leader _pos));
};

if(_pos isEqualTo [0, 0, 0]) exitWith { //unsetting the last known position
    _group setVariable[QGVAR(lastKnownPos), _pos];
    [["%1: setting %2 as last known pos for %3", __FILE_NAME__, _pos, _group], REPORT, QCOMPONENT] call EFUNC(tools,debug); 
    _pos
};

private _debug = (_group getVariable[QGVAR(logic), objNull]) getVariable[QGVAR(debug), false];
_pos = [_pos, _radius] call CBA_fnc_randPos;
_group setVariable[QGVAR(lastKnownPos), _pos, _debug];

_pos
