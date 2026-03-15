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
	["_object", objNull, [objNull, grpNull]] // can be Module_F or grpNull
];

if(isNull _object) exitWith {
	[["%1: _object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(!isServer) exitWith {
	[["%1: Should be run only on Server", __FILE_NAME__], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _units = [];
private _debug = false; //used to execute debug fnc is true
if(_object isEqualType grpNull) then {
	_units = units _object;
	_debug = _object getVariable[QGVAR(debug), false];
} else {
	if(_object isKindOf "Module_F") then {
		_units = synchronizedObjects _object;
		_debug = _object getVariable[QGVAR(debug), false]; //used for logic
	};
};

if(_units isEqualTo []) exitWith {
	[["%1: No linked units found", __FILE_NAME__], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
//Check if Synched objects are correct, only 'CAManBase' should be used, 
//if multiple units of the same group are synched just filter to unique groups
if(!(_units isEqualTypeAll objNull)) exitWith {
	[["%1: Linked types aren't of type objNull", __FILE_NAME__], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _filter = _units apply {typeOf _x};
private _hasWrongClasses = (_filter findIf {!(_x isKindOf "CAManBase")}) isNotEqualTo -1;
if(_hasWrongClasses) exitWith {
	[["%1: Linked objects do not inherit from 'CAManBase", __FILE_NAME__], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Perform unique filter
private _groups = [];
_units apply {
	_groups pushBackUnique (group _x);
};

//Handled groups
GVAR(groups) = missionNamespace getVariable[QGVAR(groups), []];
private _isAlreadyIn = false;
_groups apply {
	private _group = _x;

	if(_object isEqualType objNull) then {
		if(_object isKindOf "Module_F") then { //retrieve vars from logic and apply them to each group
			private _threat_dis = _object getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
			private _alarm_dis = _object getVariable[QGVAR(alarm_distance), ALARM_DISTANCE];
			private _debug = _object getVariable[QGVAR(debug), false];

			_group setVariable[QGVAR(threat_distance), _threat_dis, _debug];
			_group setVariable[QGVAR(alarm_distance), _alarm_dis, _debug];
			_group setVariable[QGVAR(debug), _debug, true];
		};
	};

	_isAlreadyIn = (GVAR(groups) pushBackUnique _group) isEqualTo -1;
	if(_isAlreadyIn) then {
		[["%1: %2 is already present in btc_toolchain_stealth_groups", __FILE_NAME__, _group], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
		break;
	} else {
		missionNamespace setVariable[QGVAR(groups), GVAR(groups), _group getVariable[QGVAR(debug), false]];
	};

	_group setBehaviourStrong "CARELESS";
    private _units = units _group;

	_group addEventHandler ["Deleted", {
		params ["_group"];
		GVAR(groups) deleteAt (GVAR(groups) find _group);
		missionNamespace setVariable[QGVAR(groups), GVAR(groups), _group getVariable[QGVAR(debug), false]];
	}];

	allCurators apply {
		_x addCuratorEditableObjects [_units, true];
	};

	_group setVariable[QGVAR(isEnabled), true, _group getVariable[QGVAR(debug), false]];
    _units apply {
        private _unit = _x;
        _unit disableAI "FSM";
		_unit disableAI "AUTOCOMBAT";
		_unit disableAI "AUTOTARGET";
		_unit disableAI "CHECKVISIBLE";
		_unit disableAI "COVER";
		_unit disableAI "RADIOPROTOCOL";
		_unit disableAI "TARGET";
		_unit disableAI "WEAPONAIM";
		_unit disableAI "FIREWEAPON";

        private _suppressedEH = _unit addEventHandler ["Suppressed", { 
            params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
            _group = group _unit;

            _hasTriggeredEH = _group getVariable[QGVAR(hasTriggeredSuppression), false];
            if(_hasTriggeredEH) exitWith {};

            _group setVariable[QGVAR(hasTriggeredSuppression), true];
			//Do not allow multiple Suppressed to trigger, so add a delay
			[{_this setVariable[QGVAR(hasTriggeredSuppression), false];}, _group, 0.1] call CBAFUNC(waitAndExecute);

			_threat = ((_unit getVariable[QGVAR(threat), [0, -2] select isDedicated]) + 0.5) min 1;
			_unit setVariable[QGVAR(threat), _threat, _group getVariable[QGVAR(debug), false]];
			#ifdef BTC_STEALTH_DEBUG
			[["%1: Triggered SUPPRESSED unit %2 increasing threat to %3", __FILE_NAME__, _unit, _threat], LOGS, QCOMPONENT] call EFUNC(tools,debug);
			#endif
			if(_threat >= 1) then {
				_group reveal _shooter;
				[QGVAR(goCombatEvent), [_group]] call CBAFUNC(localEvent);
				#ifdef BTC_STEALTH_DEBUG
				[["%1: Triggered SUPPRESSED unit %2 exceed threat levels", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug);
				#endif
			};
        }];
		private _killedEH = _unit addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			#ifdef BTC_STEALTH_DEBUG
			[["%1: Triggered KILLED for %2", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug);
			#endif
			_EHs = _unit getVariable[QGVAR(EHs), []];
			_EHs params [
				["_suppressedEH", -1, [123]],
				["_killedEH", -1, [123]],
				["_hitEH", -1, [123]],
				["_firedEH", -1, [123]]
			];
			_unit removeEventHandler["Suppressed", _suppressedEH];
			_unit removeEventHandler["Killed", _killedEH];
			_unit removeEventHandler["Hit", _hitEH];
			_unit removeEventHandler["FiredMan", _firedEH];

			private _group = group _unit;
			_group reveal _killer;
			[QGVAR(goCombatEvent), [group _unit]] call CBAFUNC(localEvent);
		}];

		private _hitEH = _unit addEventHandler ["Hit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			#ifdef BTC_STEALTH_DEBUG
			[format["%1: Triggered HIT for %2", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
			#endif
			
			private _group = group _unit;
			_group reveal _instigator;
			[QGVAR(goCombatEvent), [group _unit]] call CBAFUNC(localEvent);
		}];

		//this should never be removed in btc_toolchain_stealth_goCombatEvent as it has to wake up nearby CARELESS groups
		private _fireEH = _unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			
			private _group = group _unit;
			private _nearGrps = (allGroups - [_group]) select {
				(((leader _x) distance (leader _group)) < (_x getVariable[QGVAR(alarm_distance), ALARM_DISTANCE])) && 
				{_x getVariable[QGVAR(isEnabled), false]}
			};
			_nearGrps apply {
				[_x] call FUNC(removeEH);
				#ifdef BTC_STEALTH_DEBUG
				[format["%1: external group %2 set to COMBAT, distance from leader of event trigger %3",
						__FILE_NAME__, _group, (leader _x) distance (leader _group)], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
				#endif
			};

			[QGVAR(goCombatEvent), [_group]] call CBAFUNC(localEvent);
		}];

		_unit setVariable[QGVAR(EHs), [_suppressedEH, _killedEH, _hitEH, _fireEH]];
    };
};
if(_isAlreadyIn) exitWith {
	[["%1: Non-unique group found, exiting...", __FILE_NAME__], GLOBAL + REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Perform Threat Check
private _handle = missionNamespace getVariable [QGVAR(PFH_handle), -1];
if(_handle isEqualTo -1) then {
	[] call FUNC(handle);
};

//Go Combat Event
_handle = missionNamespace getVariable[QGVAR(goCombatEH_handle), -1];
if(_handle isEqualTo -1) then {
	GVAR(goCombatEH_handle) = [QGVAR(goCombatEvent), FUNC(removeEH)] call CBAFUNC(addEventHandler);
};

//debug
if(_debug) then {
	GVAR(debug_JIP) = [] remoteExecCall [QFUNC(debug), [0, -2] select isDedicated, true];
};
