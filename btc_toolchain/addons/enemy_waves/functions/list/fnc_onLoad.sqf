#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_list_onLoad

Description:
    Initializes the wave configuration lists and UI event handlers for group and unit composition on dialog load.

Parameters:
    _main_grp: CONTROL - Main controls group
    _config: CONFIG - Attribute config (optional, default: configNull)

Returns:
    NOTHING

Examples:
    (begin example)
        [_mainGroupControl] call btc_toolchain_enemy_waves_fnc_list_onLoad;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_main_grp", controlNull, [controlNull]],
    ["_config", configNull, [configNull]]
];
disableSerialization;

#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: executing list onLoad", __FILE_NAME__], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

GVAR(table) = createHashMap;
uiNamespace setVariable [QGVAR(list_grps), _main_grp];

//Wave 1
private _grp1 = _main_grp controlsGroupCtrl LIST_1;
private _grp1_list = _grp1 controlsGroupCtrl VALUE_1;

//Wave 2
private _grp2 = _main_grp controlsGroupCtrl LIST_2;
private _grp2_list = _grp2 controlsGroupCtrl VALUE_2;

_grp1_list ctrlAddEventHandler ["KeyDown", EFUNC(gui,list_keyDown)];
_grp2_list ctrlAddEventHandler ["KeyDown", EFUNC(gui,list_keyDown)];
_grp2_list ctrlAddEventHandler ["KeyUp", EFUNC(gui,list_keyUp)];

