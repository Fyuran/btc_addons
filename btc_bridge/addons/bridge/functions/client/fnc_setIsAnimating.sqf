#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_setIsAnimating_client

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_setIsAnimating_client;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_vehicle", objNull, [objNull]],
	["_isAnimating", false, [true]]
];

_vehicle setVariable[QGVAR(isAnimating), _isAnimating];
if(local _vehicle) then {
	[_isAnimating] call FUNC_O(setDIKColors);
	[_isAnimating] call FUNC_O(pictureRotation);

	/* 
	private _display = uiNamespace getVariable[QGVAR(display), displayNull];
	if(isNull _display) exitWith {
		[["%1: vehicle is local, but no display found", __FILE_NAME__], REPORT, QCOMPONENT] call BTCFUNC(tools,debug); 
	};
	private _ctrlGrp = _display displayCtrl CTRL_GRP;
	private _Q = _ctrlGrp controlsGroupCtrl 1003;
	private _Z = _ctrlGrp controlsGroupCtrl 1004;
	private _heightCtrl = _ctrlGrp controlsGroupCtrl 1006;
	private _future_height = _adjusted_height + _increment;

	switch(true) do {
		//below limit
		case (_future_height < -BRIDGE_HEIGHT_LIMIT): {
			_Z ctrlSetStructuredText parseText "<t color='#5a5958' font='PuristaBold'>[Z]</t> Decrease Bridge Height";
		};
		//above limit
		case (_future_height > BRIDGE_HEIGHT_LIMIT): {
			_Q ctrlSetStructuredText parseText "<t color='#5a5958' font='PuristaBold'>[Q]</t> Increase Bridge Height";
		};
		default {
			_Q ctrlSetStructuredText parseText "<t color='#E06B1F' font='PuristaBold'>[Q]</t> Increase Bridge Height";
			_Z ctrlSetStructuredText parseText "<t color='#E06B1F' font='PuristaBold'>[Z]</t> Decrease Bridge Height";
		};
	};
	_heightCtrl ctrlSetStructuredText parseText format["<t color='#b40379' font='PuristaBold'>Bridge Height: %1</t>", _adjusted_height];
	 */
};
