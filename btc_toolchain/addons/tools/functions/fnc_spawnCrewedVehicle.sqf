#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_spawnCrewedVehicle

Description:
    Spawns a vehicle with all empty positions filled

Parameters:
    _positionAGL: ARRAY - Origin position [x, y, z]
    _direction: NUMBER - Compass heading direction in degrees
    _class: STRING - Vehicle class
    _group: GROUP - To which group to assign to

Returns:
    ARRAY

Examples:
    (begin example)
        [getPos player, 0, "O_MRAP_02_F"] call btc_toolchain_tools_fnc_spawnCrewedVehicle;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_positionAGL", [0, 0, 0], [[]], 3],
    ["_direction", 0, [123]],
    ["_class", "", [""]],
    ["_group", grpNull, [grpNull]]
];

if (_positionAGL isEqualTo [0, 0, 0]) exitWith {
	[["%1: bad _positionAGL: %2", __FILE_NAME__, _positionAGL], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    [objNull, []]
};

if (isNull _group) then {
    private _cfg = configFile >> "CfgVehicles" >> _class >> "side";
    if (!isNumber _cfg) exitWith {
        [["%1: no side property found for %2", __FILE_NAME__, _class], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    private _side = (getNumber _cfg) call BIS_fnc_sideType;
    _group = createGroup [_side, true];
};
if (isNull _group) exitWith {
    [objNull, []]
};

private _vehicle = createVehicle [_class, _positionAGL, [], 0, "FLY"];
_group addVehicle _vehicle;
_group createVehicleCrew _vehicle;
_vehicle setDir _direction;
_vehicle setPos _positionAGL;

private _crew = units _group;
private _emptySeats = _vehicle emptyPositions ""; //Cargo
if (_emptySeats > 0) then {
    private _crewType = getText (configFile >> "CfgVehicles" >> _class >> "crew");
    if (_crewType isEqualTo "") exitWith {};

    for "_i" from 1 to _emptySeats do {
        private _unit = _group createUnit [_crewType, [0, 0, 0], [], 0, "NONE"];
        private _hasMoved = _unit moveInAny _vehicle;
        if (!_hasMoved) exitWith {
            deleteVehicle _unit;
        };

        _crew pushBack _unit;
    };
};

[_vehicle, _crew]
