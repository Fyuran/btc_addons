#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_manual_triggers_fnc_addAction

Description:
    Will add ACE action to player

Parameters:
    _logic: OBJECT - Logic module
    _actionData: ARRAY - Action data array [_triggerName, _varName, _trigger]

Returns:

Examples:
    (begin example)
        [_logic, ["TEST 1", "varName", thisTrigger]] call btc_toolchain_manual_triggers_fnc_addAction;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_logic", objNull, [objNull]],
    ["_actionData", [], [[]]] //[_triggerName, _varName, _trigger]
]; 

if (!hasInterface) exitWith {
    #ifdef BTC_DEBUG_MANUAL_TRIGGERS
    [["%1: attempted to run on !hasInterface client", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if (isNull _logic) exitWith {
    #ifdef BTC_DEBUG_MANUAL_TRIGGERS
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if(_actionData isEqualTo []) exitWith {
	#ifdef BTC_DEBUG_MANUAL_TRIGGERS
    [["%1: Empty _actionData", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

#ifdef BTC_DEBUG_MANUAL_TRIGGERS
[["%1: Adding actions %2", __FILE_NAME__, _this], LOGS, QCOMPONENT] call EFUNC(tools,debug);
if (player getVariable [QGVAR(isSpecialBoy), false]) then {
    [["%1: %2 is a special boy!", __FILE_NAME__, player], LOGS, QCOMPONENT] call EFUNC(tools,debug);
};
#endif

//Children actions
{
    _x params[
        ["_triggerName", "", [""]],
        ["_trigger", objNull, [objNull]]
    ];

    if (isNull _trigger) then {
        #ifdef BTC_DEBUG_MANUAL_TRIGGERS
        [["%1: null trigger", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        continue;
    };

    private _actionNameTokens = _triggerName splitString "_";
    private _actionName = _actionNameTokens joinString " ";
    
    private _action = [_triggerName, _actionName, "",
    {
        params ["_target","_caller","_params"];
        _params params [
            ["_thisActionName", "", [""]],
            ["_trigger", objNull, [objNull]]
        ];
        if (isNull _trigger) exitWith {};

        _trigger setVariable[QGVAR(cond), true, 0];
        
        #ifdef BTC_DEBUG_MANUAL_TRIGGERS
        [["%1: %2 has been manually activated", __FILE_NAME__, _thisActionName], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif

        (triggerActivation _trigger) params ["_by", "_type", "_repeating", "_persistent"];
        if (!_repeating) then {
            #ifdef BTC_DEBUG_MANUAL_TRIGGERS
            [["%1: %2 is non repeating, removing %3 action", __FILE_NAME__, _trigger, _thisActionName], LOGS + CHAT, QCOMPONENT] call EFUNC(tools,debug);
            #endif
            [player, 1, ["ACE_SelfActions", "btc_ace_Actions", QGVAR(menu), _thisActionName]] call ACEFUNC(interact_menu,removeActionFromObject);
        }
        else {
            [{ //flip it back on a delay, as it won't evaluate in time on Repeatable
                params["_trigger"];
                _trigger setVariable[QGVAR(cond), false, 0]; //allow rexecution
            }, [_trigger], 1] call CBAFUNC(waitAndExecute);     
        }

    }, {
        params ["_target","_caller","_params"];
        _params params [
            ["_thisActionName", "", [""]],
            ["_trigger", objNull, [objNull]]
        ];
        
        !(_trigger getVariable[QGVAR(cond), false]);
    }, {}, [_triggerName, _trigger]] call ACEFUNC(interact_menu,createAction);

    [player, 1, ["ACE_SelfActions", "btc_ace_Actions", QGVAR(menu)], _action] call ACEFUNC(interact_menu,addActionToObject);
} forEach _actionData;
