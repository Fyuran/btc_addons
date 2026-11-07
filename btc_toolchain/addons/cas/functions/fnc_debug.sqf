#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_debug

Description:
    Toggles a client-side per-frame 3D debug HUD for CAS modules and aircraft.
    Renders:
    - CAS module position, class icon, and target information.
    - Active CAS aircraft with vehicle icon, current distance from the module/target,
      status (Approaching or Diving), and planned weapon & firing mode.
    - Planned 3D trajectory lines from the aircraft to the ingress waypoint,
      dive trajectory towards the target, and direct line of sight.

Parameters:
    _veh: OBJECT

Returns:
    NUMBER - CBA Per Frame Handler handle

Examples:
    (begin example)
        [] call btc_toolchain_cas_fnc_debug;
    (end)
    (begin example)
        [true] call btc_toolchain_cas_fnc_debug;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_veh", objNull, [objNull]]
];
if (!hasInterface) exitWith {};

GVAR(debugVehs) = missionNamespace getVariable [QGVAR(debugVehs), []];
if (alive _veh && {!(_veh in GVAR(debugVehs))}) then {
    GVAR(debugVehs) pushBackUnique _veh;
};

GVAR(debugHandle) = missionNamespace getVariable [QGVAR(debugHandle), -1];
if (GVAR(debugHandle) isNotEqualTo -1) exitWith {
    GVAR(debugHandle)
};

GVAR(debugHandle) = [{
    // Render CAS Modules
    private _logics = entities QGVAR(module);
    _logics apply {
        private _logic = _x;
        if (isNull _logic) then { 
            continue; 
        };

        private _logicPosAGL = getPosVisual _logic;
        if (!([_logicPosAGL] call EFUNC(tools,isInScreen))) then {
            continue;
        };
        private _logicCfg = configOf _logic;
        private _logicIcon = getText (_logicCfg >> "icon");
        if (_logicIcon isEqualTo "") then {
            _logicIcon = "\a3\ui_f\data\map\markers\nato\b_air.paa";
        };

        drawIcon3D [
            _logicIcon,
            [1, 0.25, 0.25, 1],
            _logicPosAGL,
            1.2,
            1.2,
            0,
            "",
            1,
            0.04
        ];

        private _logicDisplayName = getText (_logicCfg >> "displayName");
        drawIcon3D [
            "",
            [1, 1, 1, 1],
            _logicPosAGL vectorAdd [0, 0, 1],
            0,
            0,
            0,
            format ["CAS Target (%1)", _logicDisplayName],
            1,
            0.035,
            "RobotoCondensedBold",
            "center"
        ];
    };

    //CAS Spawns
    private _vehDebugPos = missionNamespace getVariable [QGVAR(debugVehsPos), []];
    _vehDebugPos apply {
        private _pos = _x;
        drawIcon3D [
            "\a3\ui_f\data\map\markers\military\start_ca.paa",
            [0, 0.75, 0, 1],
            _pos,
            1.3,
            1.3,
            0,
            "",
            1,
            0.04
        ];
    }; 

    // CAS
    private _vehicles = missionNamespace getVariable [QGVAR(debugVehs), []];
    {
        private _veh = _x;
        if (!alive _veh) then {
            _vehicles deleteAt _forEachIndex;
            missionNamespace setVariable [QGVAR(debugVehs), _vehicles];
            private _debugPos = _veh getVariable [QGVAR(debugPos), []];
            private _debugPosIndex = GVAR(debugVehsPos) find _debugPos;
            if (_debugPosIndex > -1) then {
                GVAR(debugVehsPos) deleteAt _debugPosIndex;
            };

            break; 
        };

        private _vehPosAGL = getPosVisual _veh;
        if (!([_vehPosAGL] call EFUNC(tools,isInScreen))) then {
            continue;
        };
        private _vehCfg = configOf _veh;
        private _vehIcon = getText (_vehCfg >> "icon");
        if (_vehIcon isEqualTo "") then {
            _vehIcon = ["\a3\ui_f\data\map\vehicleicons\iconPlane_ca.paa", "\a3\ui_f\data\map\vehicleicons\iconHelicopter_ca.paa"] select (_veh isKindOf "Helicopter");
        };
        drawIcon3D [
            _vehIcon,
            [0.2, 0.75, 1, 1],
            _vehPosAGL,
            1.3,
            1.3,
            0,
            "",
            1,
            0.04
        ];

        private _vehDisplayName = getText (_vehCfg >> "displayName");
        drawIcon3D [
            "",
            [1, 1, 1, 1],
            _vehPosAGL vectorAdd [0, 0, 1],
            0,
            0,
            0,
            format ["CAS (%1)", _vehDisplayName],
            1,
            0.035,
            "RobotoCondensedBold",
            "center"
        ];
    } forEach _vehicles;

    private _ammos = missionNamespace getVariable [QGVAR(debugAmmo), []];
    {
        private _ammo = _x;
        if (!alive _ammo) then {
            _ammos deleteAt _forEachIndex;
            missionNamespace setVariable [QGVAR(debugAmmo), _ammos];
            break;
        };
        private _ammoPosAGL = getPosVisual _ammo;
        if (!([_ammoPosAGL] call EFUNC(tools,isInScreen))) then {
            continue;
        };
        drawIcon3D [
            "",
            [0.8, 0.1, 0, 1],
            _ammoPosAGL,
            1.3,
            1.3,
            0,
            "•",
            1,
            0.04
        ];
    } forEach _ammos;
}, 0, []] call CBAFUNC(addPerFrameHandler);

GVAR(debugHandle)
