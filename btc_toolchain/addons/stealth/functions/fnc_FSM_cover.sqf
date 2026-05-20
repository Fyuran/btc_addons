#include "..\script_component.hpp"

[
_this, 
{
	/*STATE*/
	params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};

	private _groupInCover = true;
	(units _group) apply {
		if(!(_x getVariable[QGVAR(isInCover), false])) then {
			_groupInCover = false;
			break;
		};
	};

    if(_groupInCover) then {
		[_group, 1/3] call FUNC(addThreat);
    };
}, 
{
	/*ENTER*/
	params[["_group", grpNull, [grpNull]]];
	if((units _group) isEqualTo []) exitWith {
		#ifdef BTC_DEBUG_STEALTH
		[["%1: removing _stateMachine %2", __FILE_NAME__, _stateMachine], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
		#endif
		[_stateMachine] call CBA_statemachine_fnc_delete;
	};
    
	_group setBehaviourStrong "AWARE";
	_group setCombatMode "YELLOW";
    _group setSpeedMode "FULL";
    [_group, []] call FUNC(setWaypoints);
    
    (units _group) apply {
        _x enableAI "ALL";

        _x spawn {
            sleep random 1;
            private _soundName = format[QGVAR(alarm_cry_%1), selectRandom [1, 2, 3, 4, 5]];
            [_this, _soundName] remoteExecCall["say3D", [0, -2] select isDedicated];

            private _coverData = [_this] call FUNC(findCover);
            if(_coverData isEqualTo []) exitWith {
                _this setUnitPos "DOWN";
            };
            _coverData params["_object", "_position"];
            private _debug = ((group _this) getVariable[QGVAR(logic), objNull]) getVariable[QGVAR(debug), false];
            _this setVariable[QGVAR(coverData), _coverData, _debug];
            _this doMove _position;

            private _time = CBA_missionTime + 10; //timeout
            waitUntil{(moveToCompleted _this) || (CBA_missionTime > _time)};
            doStop _this;

            private _leader = leader group _this;
            if(_this isNotEqualTo _leader) then {
                _this setVariable[QGVAR(isInCover), true, _debug];
            };
            //delay leader reactivation
            if(_this isEqualTo _leader) then {
                [_leader] call FUNC(call_reinforcements);
                _leader setVariable[QGVAR(isInCover), true];
            };
        };
    };
    
	//alert nearby groups
	[_group, _group getVariable[QGVAR(threat_distance), THREAT_DISTANCE], [_group getVariable[QGVAR(lastKnownPos), [0, 0, 0]]], {
        params[["_grp", grpNull, [grpNull]]];
        _args params["_lastKnownPos"];
        _grp setVariable[QGVAR(isReinforcement), true];
        _grp setVariable[QGVAR(reinf_location), _lastKnownPos];
        #ifdef BTC_DEBUG_STEALTH
        [["%1: %2 is reinforcing to %3", __FILE_NAME__, _grp, _lastKnownPos], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug); 
        #endif
    }] call FUNC(execNearbyGrps);

}, {
    /*EXIT*/
    params[["_group", grpNull, [grpNull]]];

    private _cover_holders = _group getVariable[QGVAR(cover_holders), []];
    _cover_holders apply {
        _cover_holders deleteAt (_cover_holders find _x);
        deleteVehicle _x;
    };

    (units _group) apply {
        _x setVariable[QGVAR(isInCover), false];
        _x setVariable[QGVAR(coverData), []];
    	_x doFollow leader _group; //release units from doStop
    };
}, "Cover"];
