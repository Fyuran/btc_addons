#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_vehicle_remoteControl

Description:


Parameters:
    _veh: OBJECT - Aircraft
    _logic: OBJECT
    
Returns:
    NOTHING

Examples:
    (begin example)
        [cursorObject, cas_1] call btc_toolchain_cas_fnc_vehicle_remoteControl;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_veh", objNull, [objNull]],
    ["_logic", objNull, [objNull]]
];

if (!canSuspend) exitWith {
    _this spawn FUNC(vehicle_remoteControl);
};

[QGVAR(blackScreen), true, 2] call BIS_fnc_blackOut;
titleText ["You are about to remote control a =BTC= CAS", "PLAIN", 0.1];
sleep 2;
waitUntil { preloadCamera (getPos _veh) };
[QGVAR(blackScreen), true, 2] call BIS_fnc_blackIn;

(findDisplay IDD_RSCDISPLAYCURATOR) closeDisplay 2;
waitUntil {isNull curatorCamera};
switchCamera (effectiveCommander _veh);
player remoteControl _veh;

private _showMarker = _logic getVariable [QGVAR(remoteHelper), false];
[{
    params [
        ["_args", [], [[]]],
        ["_thisHandle", -1, [123]]
    ];

    _args params [
        ["_veh", objNull, [objNull]],
        ["_logic", objNull, [objNull]],
        ["_showMarker", false, [true]]
    ];

    if (_showMarker) then {
        drawIcon3D [
            "\a3\ui_f\data\map\groupicons\selector_selectedEnemy_ca.paa",
            [1, 0.35, 0.2, 1],
            getPosVisual _logic,
            1,
            1,
            0,
            "",
            1,
            0.04
        ];
    };

    if (cameraOn != _veh || {!alive _veh}) exitWith {
        switchCamera player;
        player remoteControl objNull;
        [_thisHandle] call CBAFUNC(removePerFrameHandler);
        [{
            params [
                ["_veh", objNull, [objNull]],
                ["_logic", objNull, [objNull]]
            ];

            private _posASL = getPosASL _veh;
            private _originalHeight = _posASL#2;
            private _dir = vectorDir _veh;
            private _wp = (group _veh) addWaypoint [_posASL vectorAdd (_dir vectorMultiply worldSize), 0];
            _wp setWaypointBehaviour "CARELESS";
            _wp setWaypointType "MOVE";
            _wp setWaypointSpeed "FULL";
            _wp setWaypointStatements ["true", QUOTE(_veh = objectParent this; deleteVehicleCrew _veh; deleteVehicle _veh;)];
            _veh flyInHeightASL [_originalHeight, _originalHeight, _originalHeight];

            deleteVehicle _logic;
        }, [_veh, _logic]] call CBA_fnc_execNextFrame; //delay by a frame, game engine is wonky
    };
}, 0, [_veh, _logic, _showMarker]] call CBAFUNC(addPerFrameHandler);
