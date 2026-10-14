#include "XEH_PREP.hpp"
// SLIDER --- extra arguments: [_min, _max, _default, _trailingDecimals, _isPercentage]
[QGVAR(volume), "SLIDER", ["Snowstorm volume", "Set your own volume for the snow storm effects"], "=BTC= Snowstorm", [0, 1, 1, 1, true], 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo 0) then {
        [] call FUNC(clients_terminate);
    } else {
        [2] call FUNC(clients_terminate);
        [] call FUNC(clients_snowSounds);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_sounds), "CHECKBOX", ["Enable Ambient Sounds", "Enable or disable ambient sounds"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [2] call FUNC(clients_terminate);
    } else {
        [] call FUNC(clients_snowSounds);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(show_breath), "CHECKBOX", ["Show Breath", "Enable or disable breath particles"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [4] call FUNC(clients_terminate);
    } else {
        [] call FUNC(clients_breath);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_snowdust), "CHECKBOX", ["Enable Snow dust", "Enable or disable snow dust"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [6] call FUNC(clients_terminate);
    } else {
        [] call FUNC(clients_snowDust);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_ppe), "CHECKBOX", ["Enable Post Process Effects", "Enable or disable post-process"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [8] call FUNC(clients_terminate);
    } else {
        [] call FUNC(clients_postprocess);
    };
}] call CBAFUNC(addSetting);
