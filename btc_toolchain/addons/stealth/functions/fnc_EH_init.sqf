#include "..\script_component.hpp"

params[
    ["_groups", [], [[]]]
];

if(_groups isEqualTo []) exitWith {
	[["%1: _groups is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_groups apply {
    private _group = _x;
    (units _group) apply {
        private _unit = _x;
        private _suppressedEH = _unit addEventHandler ["Suppressed", { 
            params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];

            private _group = group _unit;
            private _hasTriggeredEH = _group getVariable[QGVAR(hasTriggeredSuppression), false];
            if(_hasTriggeredEH) exitWith {};

            _group setVariable[QGVAR(hasTriggeredSuppression), true];
			//Do not allow multiple Suppressed to trigger, so add a delay
			[{_this setVariable[QGVAR(hasTriggeredSuppression), false];}, _group, 0.1] call CBA_fnc_waitAndExecute;

            [_group, getPos _instigator, 5] call FUNC(setLastKnownPosition);
            private _threat = _group getVariable[QGVAR(threat), 0];
            [_group, _threat + 1.5] call FUNC(setThreat);

            #ifdef BTC_DEBUG_STEALTH
            [["%1: Triggered SUPPRESSED unit %2 increasing threat to %3", __FILE_NAME__, _unit, _group getVariable[QGVAR(threat), 0]], LOGS, QCOMPONENT] call EFUNC(tools,debug);
            #endif
        }];
        private _killedEH = _unit addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            #ifdef BTC_DEBUG_STEALTH
            [["%1: Triggered KILLED for %2", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug);
            #endif

            private _EHs = _unit getVariable[QGVAR(EHs), []];
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
            [_group, 5] call FUNC(setThreat);
        }];

        private _hitEH = _unit addEventHandler ["Hit", {
            params ["_unit", "_source", "_damage", "_instigator"];
            #ifdef BTC_DEBUG_STEALTH
            [["%1: Triggered HIT for %2", __FILE_NAME__, _unit], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
            #endif
            private _group = group _unit;
            [_group, 5] call FUNC(setThreat);
        }];


        private _fireEH = _unit addEventHandler ["FiredMan", {
            params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
            
            private _group = group _unit;
            private _hasTriggeredEH = _group getVariable[QGVAR(hasTriggeredFired), false];
            if(_hasTriggeredEH) exitWith {};

            _group setVariable[QGVAR(hasTriggeredFired), true];
			//Do not allow multiple Suppressed to trigger, so add a delay
			[{_this setVariable[QGVAR(hasTriggeredFired), false];}, _group, 0.5] call CBA_fnc_waitAndExecute;

            private _threat = _group getVariable[QGVAR(threat), 0];
            [_group, _threat + 1.5] call FUNC(setThreat);
            private _lastKnownPos = _group getVariable[QGVAR(lastKnownPos), [0, 0, 0]];
            private _nearGrps = [_unit, _group getVariable[QGVAR(threat_distance), THREAT_DISTANCE], [_lastKnownPos], {
                params[
                    ["_grp", grpNull, [grpNull]],
                    ["_args", [], [[]]]
                ];
                _args params[
                    ["_lastKnownPos", [0, 0, 0], [[]], 3]
                ];
                if(_lastKnownPos isEqualTo [0, 0, 0]) exitWith {};
                if(_grp getVariable[QGVAR(isReinforcement), false]) exitWith {};
                #ifdef BTC_DEBUG_STEALTH
                [["%1: %2 is reinforcing to %3", __FILE_NAME__, _grp, _lastKnownPos], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug); 
                #endif
                _grp setVariable[QGVAR(isReinforcement), true];
                _grp setVariable[QGVAR(reinf_location), _lastKnownPos];
            }] call FUNC(execNearbyGrps);
        }];

		_unit setVariable[QGVAR(EHs), [_suppressedEH, _killedEH, _hitEH, _fireEH]];
    };
};
