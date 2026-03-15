//Remove EHs event handlers
#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: 
    btc_toolchain_stealth_fnc_removeEH

Description:
    Removes event handlers from units and groups

Parameters:
    _group - [Group]

Returns:
    None

Examples:
    (begin example)
        [grp_1] call btc_toolchain_stealth_fnc_removeEH;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params[
	["_group", grpNull, [grpNull]]
];

if(!(_group getVariable[QGVAR(isEnabled), false])) exitWith {};
private _debug = _group getVariable[QGVAR(debug), false];

GVAR(groups) deleteAt (GVAR(groups) find _group);
missionNamespace setVariable[QGVAR(groups), GVAR(groups), _debug];

_group setVariable[QGVAR(isEnabled), false, _debug];

(units _group) apply {
	private _unit = _x;
	if(!alive _unit) exitWith {};
	_unit setVariable[QGVAR(threat), 1, _debug];
	_EHs = _unit getVariable[QGVAR(EHs), []];
	//_fireEH should never be removed here as it has to wake up nearby CARELESS groups
	_EHs params [
		["_suppressedEH", -1, [123]],
		["_killedEH", -1, [123]],
		["_hitEH", -1, [123]]
	];
	_unit removeEventHandler["Suppressed", _suppressedEH];
	_unit removeEventHandler["Killed", _killedEH];
	_unit removeEventHandler["Hit", _hitEH];

	_unit enableAI "FSM";
	_unit enableAI "AUTOCOMBAT";
	_unit enableAI "AUTOTARGET";
	_unit enableAI "CHECKVISIBLE";
	_unit enableAI "COVER";
	_unit enableAI "RADIOPROTOCOL";
	_unit enableAI "TARGET";
	_unit enableAI "WEAPONAIM";
	_unit enableAI "FIREWEAPON";
	_unit setCombatBehaviour "COMBAT";
};
#ifdef BTC_STEALTH_DEBUG
[format["%1: Removed EHs for group %2 and set to COMBAT", __FILE_NAME__, _group], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
#endif
