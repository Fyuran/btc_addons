#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_execNearbyGrps

Description:
    Finds nearby stealth AI groups within a given range of a source and executes a callback function on each.

Parameters:
    _src: OBJECT/GROUP
    _range: NUMBER
    _args: ARRAY
    _code: CODE

Returns:
    ARRAY

Examples:
    (begin example)
        [_unit, 300, [], { params ['_grp']; [_grp, 2] call btc_toolchain_stealth_fnc_addThreat; }] call btc_toolchain_stealth_fnc_execNearbyGrps;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_src", objNull, [objNull, grpNull]],
    ["_range", ALARM_DISTANCE, [123]],
    ["_args", [], [[]]],
    ["_code", {}, [{}]]
];

if(isNull _src) exitWith {
	[["%1: _src is invalid", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};
if(_range <= 0) exitWith {
	[["%1: _range is zero or neg", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

private _nearGrps = [];
if(_src isEqualType objNull) then {
    private _group = group _src;
    _nearGrps = (allGroups - [_group]) select {
        private _leader = leader _x;
        private _side = side _x;

        (_side isEqualTo (side _src)) && 
        {((_leader distance _src) <= _range)}    
    };
};

if(_src isEqualType grpNull) then {
    _nearGrps = (allGroups - [_src]) select {
        private _leader = leader _x;
        private _side = side _x;

        (_side isEqualTo (side _src)) && 
        {((_leader distance (leader _src)) <= _range)} 
    };
};

if(_nearGrps isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: no groups found nearby from %2 with range %3", __FILE_NAME__, _src, _range], LOGS, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    []
};
_nearGrps apply {
    #ifdef BTC_DEBUG_STEALTH
    [["%1: exec code to nearby grp: %2", __FILE_NAME__, _x], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
    #endif
    [_x, _args] call _code;
};

_nearGrps
