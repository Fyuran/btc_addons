#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_gui_fnc_curator_init

Description:
    Standardized Zeus curator module logic initialization.

Parameters:
    _logic: OBJECT - Module logic
    _activated: BOOLEAN - Activation state
    _okCode: CODE or STRING - Code to execute on OK click
    _abortCode: CODE or STRING - Optional abort callback (default: deleteVehicle logic)

Returns:
    NOTHING

Examples:
    (begin example)
        [_logic, _activated, { ... }] call btc_toolchain_gui_fnc_curator_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logic", objNull, [objNull]],
    ["_activated", true, [true]],
    ["_okCode", {}, [{}, ""]],
    ["_abortCode", {}, [{}, ""]]
];

if (isNull _logic) exitWith {
    #ifdef BTC_DEBUG_GUI
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

if (!_activated) exitWith {};

missionNamespace setVariable [QGVAR(curator_logic), _logic, owner _logic];

if (_abortCode isEqualTo {}) then {
    _abortCode = {
        deleteVehicle (missionNamespace getVariable [QGVAR(curator_logic), objNull]);
    };
};

[_logic, 1, _okCode, _abortCode] remoteExecCall [QFUNC(curator_build), _logic];

