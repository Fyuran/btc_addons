#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_stealth_fnc_init

Description:
    Initializes event handlers for stealth groups. Disables AI functionalities and adds event 
    handlers to detect when stealth is compromised. 
	When compromised, removeEh which removes 
    handlers and sets affected units and nearby stealth groups to COMBAT behavior.

Parameters:
    _groups - Array of groups to initialize for stealth [Array, default: []]

Returns:
    None

Examples:
    (begin example)
        [grp_1] call btc_toolchain_stealth_fnc_init;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_logic", objNull, [objNull]] // can be Module_F
];

if(isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: Should be run only on Server", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!(_logic isKindOf "Module_F")) exitWith {
	[["%1: _logic is not a Module_F", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _units = synchronizedObjects _logic;

if(_units isEqualTo []) exitWith {
	[["%1: No linked units found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
//Check if Synched objects are correct, only 'CAManBase' should be used, 
//if multiple units of the same group are synched just filter to unique groups
if(!(_units isEqualTypeAll objNull)) exitWith {
	[["%1: Linked types aren't of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _filter = _units apply {typeOf _x};
private _hasWrongClasses = (_filter findIf {!(_x isKindOf "CAManBase")}) isNotEqualTo -1;
if(_hasWrongClasses) exitWith {
	[["%1: Linked objects do not inherit from 'CAManBase", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Perform unique filter
private _groups = [];
_units apply {
	_groups pushBackUnique (group _x);
};
if(_groups isEqualTo []) exitWith {
	[["%1: No groups were found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//used to restrict communications
GVAR(radioInProgress) = false;
GVAR(groups) = []; //hold ref to groups

//retrieved from logic namespace
private _debug = _logic getVariable[QGVAR(debug), false]; //used for logic
if(_debug isEqualType 123) then { //handle some weird cases when even if typename is 'BOOL' when default it's handled as 'SCALAR'
    _debug = _debug isEqualTo 1;
};
private _investigate_offset = _logic getVariable[QGVAR(investigate_offset), 1];
private _cover_offset = _logic getVariable[QGVAR(cover_offset), 1];
private _alarm_offset = _logic getVariable[QGVAR(alarm_offset), 1];
private _limit_offset = _logic getVariable[QGVAR(limit_offset), 1];
private _threat_dis = _logic getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
private _alarm_dis = _logic getVariable[QGVAR(alarm_distance), ALARM_DISTANCE];
private _radio_delay = _logic getVariable[QGVAR(radio_delay), 60];

//set by offset
private _investigate_threshold = 1 + (_investigate_offset max 0);
private _cover_threshold = (_investigate_threshold + 1) + (_cover_offset max 0);
private _alarm_threshold = (_cover_threshold + 1)+ (_alarm_offset max 0);
private _threat_limit = (_alarm_threshold + 1) + (_limit_offset max 0); //higher number extends duration of alarm

_groups apply {
    private _group = _x;
    private _FSM = [[_group], true] call CBA_statemachine_fnc_create;
    _group setVariable[QGVAR(FSM), _FSM];
    _group setVariable[QGVAR(logic), _logic];
    _group setVariable[QGVAR(threat_distance), _threat_dis];
    _group setVariable[QGVAR(alarm_distance), _alarm_dis];
    _group setVariable[QGVAR(investigate_threshold), _investigate_threshold];
    _group setVariable[QGVAR(cover_threshold), _cover_threshold];
    _group setVariable[QGVAR(alarm_threshold), _alarm_threshold];
    _group setVariable[QGVAR(threat_limit), _threat_limit];
    _group setVariable[QGVAR(radio_delay), _radio_delay];

    [_FSM] call FUNC(FSM_init);
    
    GVAR(groups) pushBack _group;
    allCurators apply {
        private _curator = _x;
        _curator addCuratorEditableObjects [units _group, true];
    };
};

[_groups] call FUNC(EH_init);

if(_debug && {!isDedicated}) then {
    publicVariable QGVAR(groups);
	GVAR(debug_JIP) = [] remoteExecCall [QFUNC(debug), [0, -2] select isDedicated, true];
} else {
    _logic setVariable[QGVAR(debug), false];
};
