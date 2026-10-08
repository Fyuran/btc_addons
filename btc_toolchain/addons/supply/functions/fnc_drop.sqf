#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_drop

Description:
    Commands an air unit to spawn and drop supply items on a location with parachutes.

Parameters:
    _logic: OBJECT - Module logic entity
    _units: ARRAY - List of affected units
    _activated: BOOLEAN - Module activation state

Returns:
    None

Examples:
    (begin example)
        [_logic, [], true] call btc_toolchain_supply_fnc_drop;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!isServer) exitWith {
    [["%1: attempted to call %2 as client", __FILE_NAME__, QFUNC(drop)], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (!_activated) exitWith {};
if (isNull _logic) exitWith {
    [["%1: _logic is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _logicPos = getPosATL _logic;
if (surfaceIsWater _logicPos) exitWith {
    [["%1: attempting to supply over water %2", __FILE_NAME__, _logicPos], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _vehicleClass = _logic getVariable [QGVAR(vehicleClass), ""];
if (_vehicleClass isEqualTo "") exitWith {
    [["%1: empty vehicle class has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if (!isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {
    [["%1: bad vehicle class '%2' has been passed to %3", __FILE_NAME__, _vehicleClass, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _data = _logic getVariable [QGVAR(list_value), ""];
if (_data isEqualTo "") exitWith {
    [["%1: bad logic data has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
_data = fromJSON _data;
if (_data isEqualTo []) exitWith {
    [["%1: bad logic data has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _paradropData = [];
/*
    HashMap structure is as follows:
        "vehicle": STRING
        "allowDamage": BOOL
        "CLASS-diag_tickTime-hashedChars": HashMap
            "class": STRING
            "inventory": HashMap
                "CFG_CLASS_1": SCALAR
                "CFG_CLASS_2": SCALAR
                ...
*/
_data apply {
    private _paradropClass = _y get "class";
    private _paradropInventory = (_y get "inventory") apply {
        [_x, _y] params [
            ["_class", "", [""]],
            ["_amount", 1, [123]]
        ];
        [_class, _amount];
    };
    _paradropData pushBack [_paradropClass, _paradropInventory];
};
if (_paradropData isEqualTo []) exitWith {
    [["%1: empty logic data has been passed to %2", __FILE_NAME__, _logic], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _enableDamage = _logic getVariable [QGVAR(enableDamage), true];
#ifdef BTC_DEBUG_SUPPLY
[["%1: calling supply %2 with data: %3", __FILE_NAME__, _logic, [_vehicleClass, _data]], CHAT + LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

// Spawn vehicle and crew
private _veh = [_logicPos, _vehicleClass, _enableDamage] call FUNC(spawnVehicle);
if (isNull _veh) exitWith {
    [["%1: failed to spawn vehicle %2", __FILE_NAME__, _vehicleClass], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

#ifdef BTC_DEBUG_SUPPLY
[["%1: parsed data is: %2", __FILE_NAME__, _paradropData], CHAT, QCOMPONENT] call EFUNC(tools,debug);
#endif

if (_logic getVariable[QGVAR(debug), false]) then {
	[] call FUNC(debug);
	allCurators apply {
		_x addCuratorEditableObjects [[_logic], true];
	};
};

// Asynchronous flight watcher and paradrop execution
[_logicPos, _veh, _paradropData, _logic] spawn {
    params [
        ["_logicPos", [0, 0, 0], [[]]],
        ["_veh", objNull, [objNull]],
        ["_paradropData", [], []],
        ["_logic", objNull, [objNull]]
    ];

    if (_logicPos isEqualTo [0, 0, 0]) exitWith {
        [["%1: _logicPos is invalid pos: %2", __FILE_NAME__, _logicPos], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
    if (isNull _veh) exitWith {
        [["%1: _veh is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };
    if (_paradropData isEqualTo []) exitWith {
        [["%1: empty _paradropClasses", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    };

    private _time = CBA_missionTime + 300; // 5 minutes timeout
    waitUntil { (_veh distance2D _logicPos) <= 100 || CBA_missionTime >= _time };

    _paradropData apply {
        _x params [
            ["_paradropClass", "", [""]],
            ["_inventory", [], [[]]]
        ];

        if (!alive _veh) exitWith {
            #ifdef BTC_DEBUG_SUPPLY
            [["%1: veh is not alive or has become null", __FILE_NAME__], 3, QCOMPONENT] call EFUNC(tools,debug);
            #endif
        };

        [_veh, _paradropClass, _inventory] call FUNC(dropCrate);
        sleep 0.5;
    };

    // Cleanup flight and logic after egress
    [
        {
            CBA_missionTime >= (_this#1)
        },
        {
            params [
                ["_veh", objNull, [objNull]],
                ["_timeout", 0, [0]],
                ["_logic", objNull, [objNull]]
            ];

            if (!isNull _logic) then {
                deleteVehicle _logic;
            };
            if (!isNull _veh) then {
                deleteVehicle driver _veh;
                deleteVehicle _veh;
            };
            #ifdef BTC_DEBUG_SUPPLY
            [["%1: Supply drop complete, deleting _veh %2", __FILE_NAME__, _veh], 3, QCOMPONENT] call EFUNC(tools,debug);
            #endif
        },
        [_veh, CBA_missionTime + 60, _logic]
    ] call CBAFUNC(waitUntilAndExecute);
};

#ifdef BTC_DEBUG_SUPPLY
[["%1: %2 Spawning supplies...", __FILE_NAME__, _vehicleClass], 3, QCOMPONENT] call EFUNC(tools,debug);
#endif
