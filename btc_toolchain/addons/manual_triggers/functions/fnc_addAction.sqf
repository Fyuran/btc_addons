#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_manual_triggers_addAction

Description:
    Will add ACE action to player

Parameters:
    _actionNames: ARRAY of STRING or STRING
    _triggers: ARRAY of OBJECT or OBJECT

Returns:

Examples:
    (begin example)
        ["TEST 1", thisTrigger] call btc_toolchain_manual_triggers_addAction;
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

//Parent action
private _parentAction = [QGVAR(menu), "Manual Triggers", QPATHTOEF(main,data\ace_actions_icon.paa), {}, 
{ 
    (([] call BIS_fnc_admin) > 0) || 
    {isServer} || //used for editor mostly
    {player getVariable [QGVAR(isSpecialBoy), false]} || //for synched player
    {!isNull (getAssignedCuratorLogic player)} //Is player curator
}, {}, []] call ACEFUNC(interact_menu,createAction);

[player, 1, ["ACE_SelfActions", "btc_ace_Actions"], _parentAction] call ACEFUNC(interact_menu,addActionToObject);

//Children actions
private _isServerExec = _logic getVariable [QGVAR(isServer), false];
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
            ["_trigger", objNull, [objNull]],
            ["_isServerExec", false, [true]]
        ];
        if (isNull _trigger) exitWith {};

        _trigger setVariable[QGVAR(cond), true, [0, 2] select _isServerExec];

        //hint format ["%1 has been manually activated", _thisActionName];

        (triggerActivation _trigger) params ["_by", "_type", "_repeating", "_persistent"];
        if (!_repeating) then {
            #ifdef BTC_DEBUG_MANUAL_TRIGGERS
            [["%1: %2 is non repeating, removing %3 action", __FILE_NAME__, _trigger, _thisActionName], LOGS + CHAT, QCOMPONENT] call EFUNC(tools,debug);
            #endif
            [player, 1, ["ACE_SelfActions", "btc_ace_Actions", QGVAR(menu), _thisActionName]] call ACEFUNC(interact_menu,removeActionFromObject);
        }
        else {
            [{ //flip it back on a delay, as it won't evaluate in time
                params["_trigger", "_isServerExec"];
                _trigger setVariable[QGVAR(cond), false, [0, 2] select _isServerExec]; //flip it back to 0 to allow rexecution
            }, [_trigger, _isServerExec], 1] call CBA_fnc_waitAndExecute;     
        }

    }, {
        params ["_target","_caller","_params"];
        _params params [
            ["_thisActionName", "", [""]],
            ["_trigger", objNull, [objNull]]
        ];
        
        !(_trigger getVariable[QGVAR(cond), false]);
    }, {}, [_triggerName, _trigger, _isServerExec]] call ACEFUNC(interact_menu,createAction);

    [player, 1, ["ACE_SelfActions", "btc_ace_Actions", QGVAR(menu)], _action] call ACEFUNC(interact_menu,addActionToObject);
} forEach _actionData;
