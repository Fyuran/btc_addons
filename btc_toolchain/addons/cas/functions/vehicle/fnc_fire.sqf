#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_vehicle_fire

Description:


Parameters:
    _veh: OBJECT - Aircraft
    _targetPosASL: ARRAY
    _t: NUMBER
    _logic: OBJECT

Returns:
    NOTHING

Examples:
    (begin example)
        [cursorObject, "Rocket_04_HE_Plane_CAS_01_F", "Burst"] call btc_toolchain_cas_fnc_vehicle_fire;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_veh", objNull, [objNull]],
    ["_targetPosASL", [0, 0, 0], [[]], 3],
    ["_t", 0, [123]],
    ["_logic", objNull, [objNull]]
];

private _weapons = _veh getVariable [QGVAR(weapons), []];
if (_weapons isEqualTo []) exitWith {
    [["%1: no weapons found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _nearEntities = _targetPosASL nearEntities ["Land", 50];
private _target = if (_nearEntities isNotEqualTo []) then {
    selectRandom _nearEntities
} else {
    objNull
};

if (!isNull _target) then {
    _veh reveal _target;
    _veh doWatch _target;
    _veh doTarget _target;
    _weapons apply {
        //_veh setAmmo [_x, 999]; crashes the game
        _veh fireAtTarget [_target, _x];
    };
};
