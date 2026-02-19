#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_moduleInit

Description:
    Initiates snowfall, executed from a module.

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_moduleInit;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];

if(!isServer) exitWith {};
#ifdef BTC_DEBUG_SNOWSTORM
[["%1: initializing snowstorm by module _this: %2", __FILE_NAME__, _this], 3, "snowstorm"] call EFUNC(tools,debug);
#endif
private _handle = missionNamespace getVariable[QGVAR(handle), -1];
if(_activated) then {
    if(_handle isNotEqualTo -1) exitWith {
        #ifdef BTC_DEBUG_SNOWSTORM
        [["% 1: one module is already running", __FILE_NAME__], REPORT, "snowstorm"] call EFUNC(tools,debug);
        #endif
    };
    #ifdef BTC_DEBUG_SNOWSTORM
    [["%1: activating snowstorm by module: %2", __FILE_NAME__, _logic], 3, "snowstorm"] call EFUNC(tools,debug);
    #endif
    private _fogValue = _logic getVariable [QGVAR(fogValue), 0.5];
	private _fogDecay = _logic getVariable [QGVAR(fogDecay), 0];
	private _fogBase = _logic getVariable [QGVAR(fogBase), 0];
	private _duration = _logic getVariable [QGVAR(duration), -1];
	private _wind_min = _logic getVariable [QGVAR(intensity_min), 20];
	private _wind_avg = _logic getVariable [QGVAR(intensity_avg), 30];
	private _wind_max = _logic getVariable [QGVAR(intensity_max), 40];
    [_fogValue, _fogDecay, _fogBase, _duration, [_wind_min, _wind_avg, _wind_max]] call FUNC(init);
} else {
    if(_handle isEqualTo -1) then { //make sure the previous handler is removed
        #ifdef BTC_DEBUG_SNOWSTORM
        [["%1: deactivating snowstorm by module: %2", __FILE_NAME__, _logic], 3, "snowstorm"] call EFUNC(tools,debug);
        #endif
        [] remoteExecCall [QFUNC(terminate), 0];
    };
};
