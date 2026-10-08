#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_spawnFullVehicle

Description:
    Spawns a vehicle with all empty positions filled

Parameters:
    _position: ARRAY - Origin position [x, y, z]
    _direction: NUMBER - Compass heading direction in degrees
    _class: STRING - Vehicle class
    _group: GROUP - To which group to assign to

Returns:

Examples:
    (begin example)
        [getPos player, 0, "O_MRAP_02_F"] call btc_toolchain_tools_fnc_spawnFullVehicle;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_position", [0, 0, 0], [[]], 3],
    ["_direction", 0, [123]],
    ["_class", "", [""]],
    ["_group", grpNull, [grpNull]]
];

if (_position isEqualTo [0, 0, 0]) exitWith {
	[["%1: bad _position: %2", __FILE_NAME__, _position], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    [objNull, []]
};

private _vehicle = createVehicle [_class, _position, [], 0, "FLY"];
_group addVehicle _vehicle;
_group createVehicleCrew _vehicle;
_vehicle setDir _direction;

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
