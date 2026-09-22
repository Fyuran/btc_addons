#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_isPositionHidden_ASL

Description:
    Tests whether a position in ASL is occluded by terrain or objects from a threat unit or location using line-of-sight checks.

Parameters:
    _pos: ARRAY/OBJECT
    _threat: OBJECT/ARRAY

Returns:
    BOOLEAN

Examples:
    (begin example)
        private _isHidden = [getPosASL _cover, player] call btc_toolchain_stealth_fnc_isPositionHidden_ASL;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_pos", [0, 0, 0], [objNull, []], 3],
    ["_threat", objNull, [objNull, []], 3]
];

if((_pos distance _threat) > 5000) exitWith {
	#ifdef BTC_DEBUG_STEALTH
	[["%1: distance above engine limitation of 5000m", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    true
}; //Hardcoded max distance: 5000m.
if((_pos isEqualType objNull) && {isNull _pos}) exitWith {
	#ifdef BTC_DEBUG_STEALTH
	[["%1: _pos as an object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    false
};
if(_pos isEqualType objNull) then {
    _pos = getPosASL _pos;
};
if(_pos isEqualTo [0, 0, 0]) exitWith {
	#ifdef BTC_DEBUG_STEALTH
	[["%1: _pos is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    false
};

if((_threat isEqualType objNull) && {isNull _threat}) exitWith {
	#ifdef BTC_DEBUG_STEALTH
	[["%1: _threat as an object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
    false
};
if((_threat isEqualType []) && {_threat isEqualTo [0, 0, 0]}) exitWith {
	#ifdef BTC_DEBUG_STEALTH
	[["%1: _threat as an array is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	#endif
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
