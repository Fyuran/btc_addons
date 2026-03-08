#include "XEH_PREP.hpp"
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_sounds), "CHECKBOX", ["Enable Ambient Sounds", "Enable or disable ambient sounds"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [2] call FUNC(terminate_clients);
    } else {
        [] call FUNC(snowSounds_clients);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(show_breath), "CHECKBOX", ["Show Breath", "Enable or disable breath particles"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [4] call FUNC(terminate_clients);
    } else {
        [] call FUNC(breath_clients);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_snowdust), "CHECKBOX", ["Enable Snow dust", "Enable or disable snow dust"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [6] call FUNC(terminate_clients);
    } else {
        [] call FUNC(snowDust_clients);
    };
}] call CBAFUNC(addSetting);
// CHECKBOX --- extra argument: default value 
[QGVAR(enable_ppe), "CHECKBOX", ["Enable Post Process Effects", "Enable or disable post-process"], "=BTC= Snowstorm", true, 0, {
    params["_value"];
    if(not (missionNamespace getVariable[QGVAR(snowfall), false])) exitWith {};
    if(_value isEqualTo false) then {
        [8] call FUNC(terminate_clients);
    } else {
        [] call FUNC(postprocess_clients);
    };
}] call CBAFUNC(addSetting);
