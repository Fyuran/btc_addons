#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_init_post

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_init_post;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]]
];
if(isNull _vehicle) exitWith {
	[["%1: _vehicle is null", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug);
};
#ifdef BTC_DEBUG_BRIDGE
[["%1: calling initPost at %2", __FILE_NAME__, getPosASL _vehicle], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
#endif

if(isServer) then {
	private _deco = createVehicle["rhs_pontoon_end_static", [0, 0, 0], [], 0, "CAN_COLLIDE"];
	_deco animateSource ["fold_source", 1, true];
	_deco attachTo[_vehicle, DECO_OFFSET];
	_vehicle setVariable[QGVAR(deco), _deco, true];
};

private _fnc = {
	params["_vehicle"];
	if(!local _vehicle) exitWith {};
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 triggered initPost assigned EH %3", __FILE_NAME__, _vehicle, _thisEvent], CHAT + LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	private _deco = _vehicle getVariable[QGVAR(deco), objNull];
	deleteVehicle _deco;
};
_vehicle addEventHandler["Killed", _fnc];
_vehicle addEventHandler["Deleted", _fnc];

if(!hasInterface) exitWith {};
_vehicle addAction [
	"<t color='#2769e4'>Bridge Mode</t>", 
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		if(local _target) then {
			[_target] call FUNC_O(init);
			[_target] call FUNC_O(addEH);
			_target engineOn true;
		};
	}, 
	nil, 
	1.5, 
	false, 
	true, 
	"", 
	"(driver _target) isEqualTo _this && {local _target} && {!(_target getVariable[""btc_bridge_isAnimating"", false])}", 
	50, 
	false, 
	"", 
	""
];
