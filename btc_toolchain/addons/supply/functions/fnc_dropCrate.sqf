#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_dropCrate

Description:
    Spawns a supply crate behind an aircraft, attaches a parachute, populates
    its inventory cargo, registers debug tracking variables, and sets a touchdown
    watcher to detach the parachute and ignite green landing smoke.

Parameters:
    _veh: OBJECT - Aircraft performing the drop
    _paradropClass: STRING - Supply crate vehicle class name
    _inventory: ARRAY - Inventory items to fill in format [_class, _count] (default: [])

Returns:
    OBJECT - Created supply crate object (or objNull on failure)

Examples:
    (begin example)
        [_veh, "B_supplyCrate_F", [["FirstAidKit", 10]]] call btc_toolchain_supply_fnc_dropCrate;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_veh", objNull, [objNull]],
    ["_paradropClass", "", [""]],
    ["_inventory", [], [[]]]
];

if (isNull _veh || {!alive _veh}) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: veh is not alive or has become null", __FILE_NAME__], 3, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    objNull
};

if (!isClass (configFile >> "CfgVehicles" >> _paradropClass)) exitWith {
    [["%1: invalid class %2", __FILE_NAME__, _paradropClass], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    objNull
};

private _vehPosATL = getPosATL _veh;
if ((_vehPosATL#2) < 15) exitWith {
    #ifdef BTC_DEBUG_SUPPLY
    [["%1: flight path too low, must be above 15m, currently: %2", __FILE_NAME__, _vehPosATL#2], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    objNull
};

private _calculatedDropPos = _vehPosATL vectorAdd ((vectorDir _veh) vectorMultiply -15);
_calculatedDropPos = _calculatedDropPos vectorDiff [0, 0, 1];

private _supply = createVehicle [_paradropClass, [0, 0, 100], [], 0, "CAN_COLLIDE"];
_supply setPosATL _calculatedDropPos;
_supply setVectorDir (vectorDir _veh);

_veh setVariable [QGVAR(hasDroppedSupplies), true, true];
_supply setVariable [QGVAR(isSupplyCrate), true, true];
_supply setVariable [QGVAR(hasLanded), false, true];

private _activeCrates = missionNamespace getVariable [QGVAR(activeSupplyCrates), []];
_activeCrates pushBackUnique _supply;
missionNamespace setVariable [QGVAR(activeSupplyCrates), _activeCrates, true];

// Parachute must not be spawned as "FLY" as it will spawn 150m above ground
private _para = createVehicle ["I_Parachute_02_F", (getPosATL _supply) vectorAdd [0, 0, 1], [], 0, "CAN_COLLIDE"];
_para setVehicleLock "LOCKED";
_supply attachTo [_para, [0, 0, 0]];
_para setVectorDir (vectorDir _veh);
_para setVelocityModelSpace [0, 10, 0];

// Ground landing smoke and detach from parachute to avoid ground clipping
[
    {
        (getPos (_this#0)#2) <= 1 || CBA_missionTime >= (_this#1)
    },
    {
        params [
            ["_supply", objNull, [objNull]]
        ];
        if (isNull _supply) exitWith {};
        detach _supply;
        _supply setVariable [QGVAR(hasLanded), true, true];
        private _posATL = getPosATL _supply;
        private _smoke = "SmokeShellGreen" createVehicle _posATL;
        _smoke attachTo [_supply, [0, 0, 0]];
    },
    [_supply, CBA_missionTime + 50]
] call CBAFUNC(waitUntilAndExecute);

if (_inventory isNotEqualTo []) then {
    [_supply, _inventory] call FUNC(fillInventory);
};

_supply

