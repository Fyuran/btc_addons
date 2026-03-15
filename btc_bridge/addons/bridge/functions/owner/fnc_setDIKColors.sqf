#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_bridge_fnc_setDIKColors_owner

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_bridge_fnc_setDIKColors_owner;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_isAnimating", false, [true]]
];

private _display = uiNamespace getVariable[QGVAR(display), displayNull];
if(isNull _display) exitWith {
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: triggered change_state but could not find display", __FILE_NAME__], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
};
private _ctrlGrp = _display displayCtrl CTRL_GRP;
private _ctrls = allControls _ctrlGrp;
_ctrls = _ctrls - [_ctrlGrp controlsGroupCtrl 1006];

private _color = ["#E06B1F", "#5a5958"] select _isAnimating;
_ctrls apply {
	if(isNull _x) then {
		break;
	};
	private _text = ctrlText _x;
	private _key = _text regexFind["\[.*?\]", 0];
	_key = (flatten _key)#0;
	private _explanation = _text regexFind["[^\[\]]+(?=\[|$)", 0];
	_explanation = (flatten _explanation)#0;

	private _structuredText = parseText format["<t color='%1' font='PuristaBold'>%2</t>%3", _color, _key, _explanation];
	#ifdef BTC_DEBUG_BRIDGE
	[["%1: replacing _ctrl %2 text %3", __FILE_NAME__, _x, _text], LOGS, QCOMPONENT] call BTCFUNC(tools,debug);
	#endif
	_x ctrlSetStructuredText _structuredText;
};
