#include "..\script_component.hpp"
params[
    ["_pos", [0, 0, 0], [objNull, []], 3],
    ["_threat", objNull, [objNull, []], 3]
];

if((_pos distance _threat) > 5000) exitWith {
	[["%1: distance above engine limitation of 5000m", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    true
}; //Hardcoded max distance: 5000m.
if((_pos isEqualType objNull) && {isNull _pos}) exitWith {
	[["%1: _pos as an object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    false
};
if(_pos isEqualType objNull) then {
    _pos = getPosASL _pos;
};
if(_pos isEqualTo [0, 0, 0]) exitWith {
	[["%1: _pos is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    false
};

if((_threat isEqualType objNull) && {isNull _threat}) exitWith {
	[["%1: _threat as an object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    false
};
if((_threat isEqualType []) && {_threat isEqualTo [0, 0, 0]}) exitWith {
	[["%1: _threat as an array is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    false
};

private _threatPos = if(_threat isEqualType objNull) then {getPosASL _threat} else {_threat};
private _intersects = lineIntersects[
    _pos, 
    _threatPos, 
    _threat
];

if(_intersects isNotEqualTo []) exitWith {
    true;
};  

false
