#include "..\script_component.hpp"

/*
Land_Bodybag_01_black_F
Land_Bodybag_01_blue_F
Land_Bodybag_01_white_F
*/
params[
    ["_body", objNull, [objNull]],
    ["_remove", true, [false]]
];

if(!(_body in allDeadMen)) exitWith {
	[["%1: attempted to dispatch non body", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

if(_remove) then {
    private _pos = getPosASL _body;
    private _dirAndUp = [vectorDir _body, vectorUp _body];
    deleteVehicle _body;

    _body = createSimpleObject["Land_Bodybag_01_black_F", _pos, false];
    _body setVectorDirAndUp _dirAndUp;
    #ifdef BTC_DEBUG_STEALTH
    [["%1: dispatching %2 at %3", __FILE_NAME__, _body, getPosASL _body], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
    #endif
} else {
    if(_body getVariable[QGVAR(kia), false]) exitWith {};
    _body setVariable[QGVAR(kia), true];
     #ifdef BTC_DEBUG_STEALTH
    [["%1: setting %2 as KIA at %3", __FILE_NAME__, _body, getPosASL _body], LOGS, QCOMPONENT] call EFUNC(tools,debug); 
    #endif
};

_body
