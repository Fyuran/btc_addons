#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_stealth_fnc_eh_init

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
        [grp_1] call btc_toolchain_stealth_fnc_eh_init;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_logic", objNull, [objNull]]
];

if(missionNamespace getVariable[QGVAR(isEnabled), false]) exitWith {
	[["%1: Another stealth module has been detected, please do not use multiple modules", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(isNull _logic) exitWith {
	[["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
GVAR(isEnabled) = true;
GVAR(threat_distance) = _logic getVariable[QGVAR(threat_distance), THREAT_DISTANCE];
GVAR(alarm_distance) = _logic getVariable[QGVAR(alarm_distance), ALARM_DISTANCE];
GVAR(debug) = _logic getVariable[QGVAR(debug), false];
if(GVAR(debug)) then {
	publicVariable QGVAR(threat_distance);
};

private _units = synchronizedObjects _logic;
if(_units isEqualTo []) exitWith {
	[["%1: No Synched objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
//Check if Synched objects are correct, only 'CAManBase' should be used, 
//if multiple units of the same group are synched just filter to unique groups
if(!(_units isEqualTypeAll objNull)) exitWith {
	[["%1: Synched objects aren't of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
private _filter = _units apply {typeOf _x};
private _hasWrongClasses = (_filter findIf {!(_x isKindOf "CAManBase")}) isNotEqualTo -1;
if(_hasWrongClasses) exitWith {
	[["%1: Synched objects do not inherit from 'CAManBase", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

//Perform unique filter
private _groups = [];
_units apply {
	_groups pushBackUnique (group _x);
};

//Event Handlers and disableAI
_groups apply {
	_x setBehaviourStrong "CARELESS";
    private _units = units _x;
	_x setVariable[QGVAR(isEnabled), true, GVAR(debug)];
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
			_unit setVariable[QGVAR(threat), _threat, GVAR(debug)];
			#ifdef BTC_STEALTH_DEBUG
			[["%1: Triggered SUPPRESSED unit %2 increasing threat to %3", __FILE_NAME__, _unit, _threat], LOGS, QCOMPONENT] call EFUNC(tools,debug);
			#endif
			if(_threat >= 1) then {
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

			[QGVAR(goCombatEvent), [group _unit]] call CBAFUNC(localEvent);
		}];

		private _hitEH = _unit addEventHandler ["Hit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			#ifdef BTC_STEALTH_DEBUG
			[format["%1: Triggered HIT for %2", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
			#endif
			[QGVAR(goCombatEvent), [group _unit]] call CBAFUNC(localEvent);
		}];

		//this should never be removed in btc_toolchain_stealth_goCombatEvent as it has to wake up nearby CARELESS groups
		private _fireEH = _unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			[QGVAR(goCombatEvent), [group _unit]] call CBAFUNC(localEvent);
		}];

		_unit setVariable[QGVAR(EHs), [_suppressedEH, _killedEH, _hitEH, _fireEH]];
    };
};

//Remove EHs event handlers
private _fnc_removeEh = {
	params[
		["_group", grpNull, [grpNull]]
	];

	if(!(_group getVariable[QGVAR(isEnabled), false])) exitWith {};

	_nearGrps = allGroups select {
		(((leader _x) distance (leader _group)) < GVAR(alarm_distance)) && 
		{_x getVariable[QGVAR(isEnabled), false]}
	};
	_nearGrps apply {
		_x setVariable[QGVAR(isEnabled), false, GVAR(debug)];
		#ifdef BTC_STEALTH_DEBUG
		if(_x isNotEqualTo _group) then {
			[format["%1: external group %2 set to COMBAT, distance from leader of event trigger %3",
				 __FILE_NAME__, _group, (leader _x) distance (leader _group)], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		};
		#endif
	};
	_units = flatten(_nearGrps apply {units _x});
	_units apply {
		private _unit = _x;
		if(!alive _unit) exitWith {};
		_unit setVariable[QGVAR(threat), 1, GVAR(debug)];
		_EHs = _unit getVariable[QGVAR(EHs), []];
		//_fireEH should never be removed here as it has to wake up nearby CARELESS groups
		_EHs params [
			["_suppressedEH", -1, [123]],
			["_killedEH", -1, [123]],
			["_hitEH", -1, [123]]
		];
		_unit removeEventHandler["Suppressed", _suppressedEH];
		_unit removeEventHandler["Killed", _killedEH];
		_unit removeEventHandler["Hit", _hitEH];

		_unit enableAI "FSM";
		_unit enableAI "AUTOCOMBAT";
		_unit enableAI "AUTOTARGET";
		_unit enableAI "CHECKVISIBLE";
		_unit enableAI "COVER";
		_unit enableAI "RADIOPROTOCOL";
		_unit enableAI "TARGET";
		_unit enableAI "WEAPONAIM";
		_unit enableAI "FIREWEAPON";
		_unit setCombatBehaviour "COMBAT";
	};
	#ifdef BTC_STEALTH_DEBUG
	[format["%1: Removed EHs for group %2 and set to COMBAT", __FILE_NAME__, _group], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
	#endif
};

GVAR(goCombatEH_handle) = [QGVAR(goCombatEvent), _fnc_removeEh] call CBAFUNC(addEventHandler);

//Perform Threat Check
[_groups] call FUNC(handle);
