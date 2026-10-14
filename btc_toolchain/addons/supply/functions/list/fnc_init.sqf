#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_init

Description:
    Initializes supply list controls with event handlers for adding, removing, and managing items.

Parameters:
    _main_grp: CONTROL - Main control group containing the supply list interface
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_mainGroup] call btc_toolchain_supply_fnc_list_init;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_main_grp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];
disableSerialization;

#ifdef BTC_DEBUG_SUPPLY
[["%1: executing groups init", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

GVAR(table) = createHashMap;
uiNamespace setVariable [QGVAR(list_grps), _main_grp];

//Group 1
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

//Group 2
private _grp2 = _main_grp controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;

_grp1_list ctrlAddEventHandler ["KeyDown", EFUNC(gui,list_keyDown)];
_grp2_list ctrlAddEventHandler ["KeyDown", EFUNC(gui,list_keyDown)];
_grp2_list ctrlAddEventHandler ["KeyUp", EFUNC(gui,list_keyUp)];
