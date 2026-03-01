#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_c4booby_fnc_timer

Description:
    Timer function for bomb defusal

Parameters:


Returns:

Examples:
    (begin example)
        _result = [] call btc_toolchain_c4booby_fnc_timer;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

params[
	["_obj",objNull,[objNull]],
    ["_end_time",60,[0]],
	["_max_colors",1,[0]]
];
if(isNull _obj) exitWith {
    [["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _start_time = CBA_missionTime;

private _handle = [{
    (_this#0) params["_start_time","_end_time","_max_colors","_obj"];
    _end_time = _obj getVariable [QGVAR(endtime), _end_time]; //in case _end_time is changed
    _elapsed_time = CBA_missionTime - _start_time;
    _countdown = _end_time - _elapsed_time;
    if(_countdown <= 0) exitWith {
		[_this#1] call CBAFUNC(removePerFrameHandler);
		_inputed_colors = _obj getVariable [QGVAR(input_wire_colors),[]];
		_missing_colors = _max_colors - (count _inputed_colors);
		for "_i" from 1 to _missing_colors do {_inputed_colors pushBack ""};
		_obj setVariable [QGVAR(input_wire_colors), _inputed_colors];
	};
    _sound_interval = _obj getVariable [QGVAR(sound_interval), 2];
    _sound = _obj getVariable [QGVAR(sound), QGVAR(timerClick)];
    private _targets = _obj nearEntities ["CAManBase", 50];
    if(_sound_interval > 0) then { //clusterfuck of if statements to get 3 intervals of different sounds
        if(round(_countdown) % _sound_interval == 0) then {
            [QACEGVAR(medical_feedback,forceSay3D), [_obj, _sound, 50], _targets] call CBAFUNC(targetEvent);
        };
        if(_countdown <= 10 && {_countdown > 5}) then {
            _obj setVariable [QGVAR(sound), QGVAR(timerClickShort)];
            _obj setVariable [QGVAR(sound_interval), 1];
        };
        if(_countdown <= 5) then {
            _obj setVariable [QGVAR(sound_interval), 0];
        };
    } else {
        if(_sound_interval isEqualTo 0) then {
            #ifdef BTC_DEBUG_C4BOOBY
            [["%1: c4booby %2 at %3", __FILE_NAME__, typeOf _obj, getPosATL _obj], LOGS, QCOMPONENT] call EFUNC(tools,debug);
            #endif
            [QACEGVAR(medical_feedback,forceSay3D), [_obj, QGVAR(timerEnd), 50], _targets] call CBAFUNC(targetEvent);
            _obj setVariable [QGVAR(sound_interval), -1];
        };
    };

    _obj setVariable [QGVAR(time), _countdown,true];
}, 1, [_start_time, _end_time, _max_colors, _obj]] call CBAFUNC(addPerFrameHandler);

_obj setVariable [QGVAR(timer_handle), _handle];
