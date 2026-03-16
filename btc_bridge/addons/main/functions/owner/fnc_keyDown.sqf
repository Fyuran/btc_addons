#include "\a3\ui_f\hpp\definedikcodes.inc"
#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_keyDown_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_keyDown_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
disableSerialization;
params [
	["_display", displayNull, [displayNull]], 
	["_key", -1, [123]]
];

if(!local GVAR(vehicle)) exitWith {
	[["%1: _vehicle is not local anymore", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
	_display closeDisplay 1;
};
private _isAnimating = GVAR(vehicle) getVariable[QGVAR(isAnimating), false];

private _segments = GVAR(vehicle) getVariable[QGVAR(segments), []];
private _segments_count = count _segments;
private _uid = GVAR(vehicle) getVariable[QGVAR(JIPUID), ""];

//Undo All will close Display, should run when bridge segments are still local vehicles
if(_key isEqualTo DIK_ESCAPE) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_ESCAPE", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	//Display Unload deletes camera, and helper


	[GVAR(vehicle), true] remoteExec [QFUNC_C(removeAll), 0];
	[GVAR(vehicle), player] remoteExecCall [QFUNC_S(removeEH), [0, 2] select isMultiplayer];
	[GVAR(vehicle)] call FUNC_O(eraseJIP);
};

//Beyond this wait for animation
if(_isAnimating) exitWith {};
//Close UI, adds end segment if there is at least one segment
if(_key isEqualTo DIK_NUMPADENTER) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_NUMPADENTER", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif

	if(_segments isEqualTo []) exitWith {};
	if((_segments_count) isEqualTo 1) exitWith {};

	
	[GVAR(vehicle), true] remoteExec [QFUNC_C(addNext), 0]; //_isEnd will call for replace which will remove server EHs
	_display closeDisplay 1;
	[GVAR(vehicle)] call FUNC_O(eraseJIP);
}; 

private _adjusted_height = GVAR(vehicle) getVariable[QGVAR(adjusted_height), 0];
//Decrease bridge height
if(_key isEqualTo DIK_Z) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_Z", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	if(_segments isEqualTo []) exitWith {};
	private _jipID = format["btc_bridge_%1_%2_height", _uid, _adjusted_height];
	[GVAR(vehicle), false] remoteExec [QFUNC_C(setHeight), 0, _jipID];
};

//Increase bridge height
if(_key isEqualTo DIK_Q) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_Q", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	if(_segments isEqualTo []) exitWith {};
	private _jipID = format["btc_bridge_%1_%2_height", _uid, _adjusted_height];
	[GVAR(vehicle), true] remoteExec [QFUNC_C(setHeight), 0, _jipID];
};

//Bridge Extension
//Start/End rhs_pontoon_end_static
//Segment rhs_pontoon_static
if(_key isEqualTo DIK_NUMPADPLUS) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_NUMPADPLUS", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	private _jipID = format["btc_bridge_%1_segment_%2", _uid, _segments_count];
	[GVAR(vehicle)] remoteExec [QFUNC_C(addNext), 0, _jipID];
};

if(_key isEqualTo DIK_NUMPADMINUS) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggering DIK_NUMPADMINUS", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	if(_segments isEqualTo []) exitWith {};

	private _jipID = format["btc_bridge_%1_segment_%2", _uid, _segments_count - 1];
	[GVAR(vehicle), true] remoteExec [QFUNC_C(removeLast), 0, _jipID];
};
