#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_manualTransition

Description:
    Applies manual transition to a stealth FSM

Parameters:
    _state: STRING

Returns:

Examples:
    (begin example)
        ["Alert", thisTrigger] call btc_toolchain_stealth_fnc_manualTransition;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_state", "Alert", [""]],
    ["_obj", objNull, [objNull]]
];

if (isNull _obj) exitWith {
	[["%1: _obj is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (_state isEqualTo "") exitWith {
	[["%1: _state is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if (!(_state in GVAR(allowed_states))) exitWith {
	[["%1: %2 is not in %3", __FILE_NAME__, _state, GVAR(allowed_states)], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _synchedObjs = synchronizedObjects _obj;

if(_synchedObjs isEqualTo []) exitWith {
	[["%1: No linked objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(!(_synchedObjs isEqualTypeAll objNull)) exitWith {
	[["%1: Linked types aren't of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _groups = [];
_synchedObjs apply {
    private _logicGroups = _x getVariable[QGVAR(groups), []];
    _logicGroups apply {_groups pushBackUnique _x};
};
if (_groups isEqualTo []) exitWith {
	[["%1: _groups are empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

_groups apply {
    private _FSM = _x getVariable [QGVAR(FSM), locationNull];
    if (isNull _FSM) then {
        #ifdef BTC_DEBUG_STEALTH
        [["%1: group _FSM is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        continue;
    };

    private _currentState = [_x, _FSM] call CBA_statemachine_fnc_getCurrentState;
    if (_currentState isEqualTo "") then {
        #ifdef BTC_DEBUG_STEALTH
        [["%1: group _currenState is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        continue;
    };

    [_x, _FSM, _currentState, _state, {
        #ifdef BTC_DEBUG_STEALTH
        [["%1: %2 manually transitioned from %3 to %4", __FILE_NAME__,
            _this, _thisOrigin, _thisTarget], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif

    }, QFUNC(manualTransition)] call CBA_statemachine_fnc_manualTransition;
};

