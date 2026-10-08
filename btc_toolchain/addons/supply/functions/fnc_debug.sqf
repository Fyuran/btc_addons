#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_debug

Description:
    Toggles a client-side per-frame 3D debug HUD for supply drop modules.
    Renders:
    - Supply module position and its config icon.
    - Supply transport vehicle icon over the aircraft while en route (stops drawing
      once supplies have been spawned).
    - Class icons and labels for spawned supply crates.
    - Projected landing spot (LZ) calculated in real time from supply/parachute
      velocity, stopping once supplies are close to the ground (<= 3m ATL).

Parameters:
    _enable: BOOL - Toggle or explicitly enable/disable (default: toggle)

Returns:
    NUMBER - CBA Per Frame Handler handle (-1 if disabled)

Examples:
    (begin example)
        [] call btc_toolchain_supply_fnc_debug;
    (end)
    (begin example)
        [true] call btc_toolchain_supply_fnc_debug;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_enable", true, [true]]
];

if (!hasInterface) exitWith {};

private _currentHandle = missionNamespace getVariable [QGVAR(debug_PFH_handle), -1];

// If disabling or toggling off
if (!_enable) exitWith {
    if (_currentHandle isNotEqualTo -1) then {
        [_currentHandle] call CBA_fnc_removePerFrameHandler;
        missionNamespace setVariable [QGVAR(debug_PFH_handle), -1];
        #ifdef BTC_DEBUG_SUPPLY
        [["%1: debug PFH stopped (handle: %2)", __FILE_NAME__, _currentHandle], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        systemChat "Supply Debug: OFF";
    };
    -1
};

// If already running just ignore
if (_currentHandle isNotEqualTo -1) exitWith {};

private _handle = [{
    // 1. Render Supply Modules
    private _modules = entities QGVAR(module);
    if (_modules isEqualTo []) then {
        _modules = allMissionObjects QGVAR(module);
    };

    _modules apply {
        private _module = _x;
        if (isNull _module) then { continue; };

        private _modPos = getPosVisual _module;
        private _modCfg = configOf _module;
        private _modIcon = getText (_modCfg >> "icon");

        // Draw module icon
        drawIcon3D [
            _modIcon,
            [0.2, 0.9, 0.3, 1],
            _modPos vectorAdd [0, 0, 0.6],
            1.2,
            1.2,
            0,
            "",
            1,
            0.04
        ];

        private _vehClass = _module getVariable [QGVAR(vehicleClass), ""];
        drawIcon3D [
            "",
            [1, 1, 1, 1],
            _modPos vectorAdd [0, 0, 1.2],
            0,
            0,
            0,
            format ["Supply Module (%1)", _vehClass],
            1,
            0.035,
            "RobotoCondensedBold",
            "center"
        ];
    };

    // 2. Render Supply Transport Vehicles (stops once supplies have been spawned)
    private _vehicles = missionNamespace getVariable [QGVAR(activeVehicles), []];
    if (_vehicles isEqualTo []) then {
        _vehicles = (entities "Air") select { _x getVariable [QGVAR(isSupplyVehicle), false] };
    };

    _vehicles apply {
        private _veh = _x;
        if (isNull _veh || {!alive _veh}) then { continue; };

        // Stop drawing the vehicle icon when air vehicle has spawned supplies
        private _hasDropped = _veh getVariable [QGVAR(hasDroppedSupplies), false];
        if (!_hasDropped) then {
            private _vehPos = getPosVisual _veh;
            private _vehCfg = configOf _veh;
            private _vehIcon = getText (_vehCfg >> "icon");
            if (_vehIcon isEqualTo "") then {
                _vehIcon = "\a3\ui_f\data\map\vehicleicons\iconHelicopter_ca.paa";
            };

            // Draw vehicle icon over the aircraft
            drawIcon3D [
                _vehIcon,
                [0.2, 0.7, 1, 1],
                _vehPos vectorAdd [0, 0, 3],
                1.3,
                1.3,
                0,
                "",
                1,
                0.04
            ];

            drawIcon3D [
                "",
                [1, 1, 1, 1],
                _vehPos vectorAdd [0, 0, 4.3],
                0,
                0,
                0,
                getText (_vehCfg >> "displayName"),
                1,
                0.035,
                "RobotoCondensedBold",
                "center"
            ];

            // Draw line to target drop position if known
            private _dropPos = _veh getVariable [QGVAR(dropPos), []];
            if (_dropPos isNotEqualTo []) then {
                drawLine3D [_vehPos, ASLToAGL (ATLToASL _dropPos), [0.3, 0.8, 1, 0.6], 1];
            };
        };
    };

    // 3. Render Spawned Supply Crates & Projected Landing Spots
    private _crates = missionNamespace getVariable [QGVAR(activeSupplyCrates), []];
    if (_crates isEqualTo []) then {
        _crates = (allMissionObjects "All") select { _x getVariable [QGVAR(isSupplyCrate), false] };
    };

    _crates apply {
        private _supply = _x;
        if (isNull _supply) then { continue; };

        private _supplyPos = getPosVisual _supply;
        private _supplyCfg = configOf _supply;
        private _supplyIcon = getText (_supplyCfg >> "icon");
        if (_supplyIcon isEqualTo "") then {
            _supplyIcon = "\a3\ui_f\data\map\vehicleicons\iconCrate_ca.paa";
        };

        // Draw supply crate class icon
        drawIcon3D [
            _supplyIcon,
            [1, 0.85, 0.2, 1],
            _supplyPos vectorAdd [0, 0, 0.5],
            1.2,
            1.2,
            0,
            "",
            1,
            0.04
        ];

        drawIcon3D [
            "",
            [1, 1, 1, 1],
            _supplyPos vectorAdd [0, 0, 1.0],
            0,
            0,
            0,
            getText (_supplyCfg >> "displayName"),
            1,
            0.035,
            "RobotoCondensedBold",
            "center"
        ];

        // 4. Calculate Landing Spot through velocity
        // Stop drawing the landing spot once supplies are close to the ground (<= 3m ATL or landed)
        private _posATL = getPosATL _supply;
        private _altitude = _posATL#2;
        private _hasLanded = _supply getVariable [QGVAR(hasLanded), false];

        if (_altitude > 3 && {!_hasLanded}) then {
            // Retrieve velocity from attached parachute if attached, otherwise from the supply crate
            private _parent = attachedTo _supply;
            private _vel = if (!isNull _parent) then { velocity _parent } else { velocity _supply };
            _vel params ["_vx", "_vy", "_vz"];

            // When falling, downward velocity vz is negative
            private _downwardSpeed = -_vz;
            if (_downwardSpeed < 0.5) then {
                _downwardSpeed = 6.0; // fallback parachute descent speed
            };

            private _timeToLand = _altitude / _downwardSpeed;
            private _dx = _vx * _timeToLand;
            private _dy = _vy * _timeToLand;

            private _landingPosATL = [(_posATL#0) + _dx, (_posATL#1) + _dy, 0];
            private _landingPosAGL = ASLToAGL (ATLToASL _landingPosATL);

            // Draw landing spot target icon
            drawIcon3D [
                "\a3\ui_f\data\map\mapcontrol\taskIcon_ca.paa",
                [0.2, 1, 0.3, 1],
                _landingPosAGL vectorAdd [0, 0, 0.3],
                1.3,
                1.3,
                0,
                "",
                1,
                0.04
            ];

            drawIcon3D [
                "",
                [1, 1, 1, 1],
                _landingPosAGL vectorAdd [0, 0, 0.9],
                0,
                0,
                0,
                format ["Landing ETA: %1s", round _timeToLand],
                1,
                0.035,
                "RobotoCondensedBold",
                "center"
            ];

            // Draw 3D trajectory line from crate to landing spot
            drawLine3D [_supplyPos, _landingPosAGL, [0.2, 1, 0.3, 0.8], 2];
        };
    };
}, 0, []] call CBA_fnc_addPerFrameHandler;

missionNamespace setVariable [QGVAR(debug_PFH_handle), _handle];
#ifdef BTC_DEBUG_SUPPLY
[["%1: debug PFH started (handle: %2)", __FILE_NAME__, _handle], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
systemChat "Supply Debug: ON";

_handle

