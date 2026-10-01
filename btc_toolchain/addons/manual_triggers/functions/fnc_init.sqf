#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_manual_triggers_init

Description:
    Used by module to parse triggers, extract their vehicleVarNames(Editor names basically), 
    fill the ones that are missing by their loop index and add ACE actions.
    Names will be formatted following layout "VAR_NAME" to "VAR NAME" if possible

Parameters:
    _logic: OBJECT

Returns:

Examples:
    (begin example)
        this] call btc_toolchain_manual_triggers_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[ 
	["_logic", objNull, [objNull]]
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

private _synchedObjs = synchronizedObjects _logic;
if(_synchedObjs isEqualTo []) exitWith {
	[["%1: No linked objects found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(!(_synchedObjs isEqualTypeAll objNull)) exitWith {
	[["%1: Linked types aren't of type objNull", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_MANUAL_TRIGGERS
[["%1: Init module %2", __FILE_NAME__, _this], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _actionData = [];
{
    private _obj = _x;
    if (isNull _obj) then {
        #ifdef BTC_DEBUG_MANUAL_TRIGGERS
        [["%1: a null object is synched?", __FILE_NAME__, _obj], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        continue;
    };

    //In case we're dealing with a soldier character
    if (_obj isKindOf "CAManBase") then {
        #ifdef BTC_DEBUG_MANUAL_TRIGGERS
        [["%1: setting %2 as a special boy", __FILE_NAME__, _obj], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        _obj setVariable [QGVAR(isSpecialBoy), true, true];

        continue;
    };

    //In case we're dealing with a trigger
    if (_obj isKindOf "EmptyDetector") then {
        private _triggerName = vehicleVarName _obj;
        if (_triggerName isEqualTo "") then {
            _triggerName = format["TRIGGER_%1", _forEachIndex];
            _obj setVehicleVarName _triggerName;
        };

        //set up our manual condition for trigger condition, without fucking shit up, hopefully
        private _triggerStatements = triggerStatements _obj; // Array with [condition, activation, deactivation]
        private _triggerCond = _triggerStatements#0;

        _triggerCond = _triggerCond regexReplace ["this", format["(thisTrigger getVariable[""%1"", false] || this)", QGVAR(cond)]];
        _obj setTriggerStatements[_triggerCond, _triggerStatements#1, _triggerStatements#2];

        _actionData pushBack [_triggerName, _obj];
    };
} forEach _synchedObjs;

[_logic, _actionData] remoteExecCall [QFUNC(addAction), [0, -2] select isDedicated, true];
