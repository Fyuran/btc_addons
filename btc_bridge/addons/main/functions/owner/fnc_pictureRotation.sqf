#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_pictureRotation_owner

Description:
    Starts or stops a per-frame handler to animate the rotating loading icon on the bridge HUD while an operation is in progress.

Parameters:
    _isAnimating: BOOLEAN

Returns:

Examples:
    (begin example)
        [true] call btc_bridge_fnc_pictureRotation_owner;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_isAnimating", false, [true]]
];
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: %2 Attempted with no interface", __FILE_NAME__, clientOwner], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

private _display = uiNamespace getVariable[QGVAR(display), displayNull];
if(isNull _display) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: could not find _display", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
private _picture = _display displayCtrl 1201;
if(isNull _picture) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: could not find _picture", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};

private _color = [[0, 1, 0, 1], [1, 0, 0, 1]] select _isAnimating;
_picture ctrlSetTextColor _color;

if(_isAnimating) then {
	GVAR(picture_rotation_handle) = [{
		(_this#0) params[
			["_picture", controlNull, [controlNull]]
		];
		if(isNull _picture) exitWith {
			#ifdef BTC_DEBUG_BRIDGE
			[["%1: _picture is null, aborting pfh", __FILE_NAME__], CHAT, QCOMPONENT] call BTCFUNC(tools,debug);
			#endif
			[_this#1] call CBA_fnc_removePerFrameHandler;
		};
		
		if(GVAR(vehicle) getVariable[QGVAR(isAnimating), false]) then {
			private _angleArr = ctrlAngle _picture;
			private _newAngle = ((_angleArr#0) + 2) % 360;
			_angleArr set [0, _newAngle];
			_picture ctrlSetAngle _angleArr;
		};
	}, 0, [_picture]] call CBA_fnc_addPerFrameHandler;
} else {
	[GVAR(picture_rotation_handle)] call CBA_fnc_removePerFrameHandler;
};
