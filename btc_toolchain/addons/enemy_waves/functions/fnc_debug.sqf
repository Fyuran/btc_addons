#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_enemy_waves_fnc_debug

Description:
    Toggles a client-side per-frame 3D debug HUD for enemy_waves modules.
    Renders module position with its config icon, timeout, units quantity,
    synced waypoint modules with their icons, waypoint types, formations,
    behaviors, combat modes, speeds, radii, connects them with lines
    from the module down to the last waypoint, and displays live wave group
    status (formation, behavior, unit count, speed, combat mode) at the
    group units' centroid elevated 5 meters ATL.

Parameters:
    _enable: BOOL - Toggle or explicitly enable/disable (default: toggle)

Returns:
    NUMBER - CBA Per Frame Handler handle (-1 if disabled)

Examples:
    (begin example)
        [] call btc_toolchain_enemy_waves_fnc_debug;
    (end)
    (begin example)
        [true] call btc_toolchain_enemy_waves_fnc_debug;
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
        #ifdef BTC_DEBUG_ENEMY_WAVES
        [["%1: debug PFH stopped (handle: %2)", __FILE_NAME__, _currentHandle], LOGS, QCOMPONENT] call EFUNC(tools,debug);
        #endif
        systemChat "Enemy Waves Debug: OFF";
    };
    -1
};

// If already running and asked to enable, just ignore
if (_currentHandle isNotEqualTo -1) exitWith {};

private _handle = [{
    // Fetch all enemy waves modules in the mission
    private _modules = entities QGVAR(module);
    if (_modules isEqualTo []) then {
        _modules = allMissionObjects QGVAR(module);
    };
    if (_modules isEqualTo []) exitWith {};

    _modules apply {
        private _module = _x;
        if (isNull _module) then { continue; };

        private _modPos = getPosVisual _module;

        // Retrieve module config icon
        private _modCfg = configOf _module;
        private _modIcon = getText (_modCfg >> "icon");

        // Side color
        private _sideRaw = _module getVariable [QGVAR(side), east];
        private _side = _sideRaw call BIS_fnc_sideType;
        private _sideColor = switch (_side) do {
            case west:        { [0.2, 0.5, 1, 1] };
            case east:        { [1, 0.2, 0.2, 1] };
            case resistance:  { [0.2, 0.9, 0.2, 1] };
            case civilian:    { [0.8, 0.4, 0.9, 1] };
            default           { [1, 1, 1, 1] };
        };

        // Render module icon at position
        drawIcon3D [
            _modIcon,
            _sideColor,
            _modPos vectorAdd [0, 0, 0.6],
            1.2,
            1.2,
            0,
            "",
            1,
            0.04
        ];

        // Retrieve timeout and unit quantities
        private _timeout = _module getVariable [QGVAR(timeout), 60];
        private _listRaw = _module getVariable [QGVAR(list_value), ""];
        private _groupsData = if (_listRaw isEqualType "") then {
            if (_listRaw isEqualTo "") then { createHashMap } else { fromJSON _listRaw };
        } else {
            _listRaw
        };

        private _totalUnits = 0;
        private _totalGroups = 0;

        if (_groupsData isEqualType createHashMap) then {
            _totalGroups = count _groupsData;
            {
                private _groupClasses = _y;
                if (_groupClasses isEqualType []) then {
                    {
                        if (_x isEqualType []) then {
                            _x params [["_class", "", [""]], ["_quantity", 1, [123]]];
                            _totalUnits = _totalUnits + _quantity;
                        };
                    } forEach _groupClasses;
                };
            } forEach _groupsData;
        } else {
            if (_groupsData isEqualType []) then {
                _totalGroups = count _groupsData;
                {
                    private _groupClasses = _x;
                    if (_groupClasses isEqualType []) then {
                        {
                            if (_x isEqualType []) then {
                                _x params [["_class", "", [""]], ["_quantity", 1, [123]]];
                                _totalUnits = _totalUnits + _quantity;
                            };
                        } forEach _groupClasses;
                    };
                } forEach _groupsData;
            };
        };

        // Render text above the module
        drawIcon3D ["", [1, 1, 1, 1], _modPos vectorAdd [0, 0, 1.2], 0, 0, 0, format ["Timeout: %1s", _timeout], 1, 0.035, "RobotoCondensedBold", "center"];
        drawIcon3D ["", [1, 0.85, 0.2, 1], _modPos vectorAdd [0, 0, 1.5], 0, 0, 0, format ["Units: %1 | Waves: %2", count (_module getVariable [QGVAR(wave_units), []]), _totalGroups], 1, 0.035, "RobotoCondensedBold", "center"];

        // Retrieve synced waypoint modules chain
        private _wpModules = _module getVariable [QGVAR(wpModules), []];
        if (_wpModules isEqualTo []) then {
            private _synced = (synchronizedObjects _module) select {_x isKindOf QGVAR(waypoint_module)};
            if (_synced isNotEqualTo []) then {
                private _chain = [];
                private _curr = _synced#0;
                while {!isNull _curr && {!(_curr in _chain)}} do {
                    _chain pushBack _curr;
                    private _nextList = (synchronizedObjects _curr) select {
                        _x isKindOf QGVAR(waypoint_module) && {!(_x in _chain)}
                    };
                    _curr = if (_nextList isNotEqualTo []) then {_nextList#0} else {objNull};
                };
                _wpModules = _chain;
            };
        };

        // Render line and waypoint modules
        private _prevPos = _modPos vectorAdd [0, 0, 0.6];
        {
            private _wpModule = _x;
            if (isNull _wpModule) then { continue; };
            private _wpPos = (getPosVisual _wpModule) vectorAdd [0, 0, 0.6];

            // Connect with a line going from module down through each waypoint to the last
            drawLine3D [_prevPos, _wpPos, [1, 0.6, 0.1, 1]];
            _prevPos = _wpPos;

            // Retrieve waypoint config & attributes
            private _wpCfg = _wpModule getVariable [QGVAR(wp_cfg), configNull];
            if (_wpCfg isEqualType "") then {
                _wpCfg = [_wpCfg] call EFUNC(tools,strToCfg);
            };

            private _wpType = "MOVE";
            private _wpIcon = "";
            if (!(isNull _wpCfg) && {isClass _wpCfg}) then {
                _wpType = getText (_wpCfg >> "displayName");
                if (_wpType isEqualTo "") then {
                    _wpType = getText (_wpCfg >> "type");
                };
                _wpIcon = getText (_wpCfg >> "icon");
            };
            if (_wpIcon isEqualTo "") then {
                _wpIcon = getText ((configOf _wpModule) >> "icon");
            };
            if (_wpIcon isEqualTo "") then {
                _wpIcon = "\a3\ui_f\data\map\markers\nato\b_inf.paa";
            };

            private _file = _wpModule getVariable [QGVAR(file), ""];
            if (_file isNotEqualTo "") then {
                _wpType = format ["SCRIPTED (%1)", _file];
            };

            private _combatMode = _wpModule getVariable [QGVAR(combat_mode), "YELLOW"];
            private _behavior = _wpModule getVariable [QGVAR(behavior), "AWARE"];
            private _formation = _wpModule getVariable [QGVAR(formation), "NO CHANGE"];
            private _speed = _wpModule getVariable [QGVAR(speed), "UNCHANGED"];
            private _radius = _wpModule getVariable [QGVAR(completion_radius), 0];

            // Render waypoint icon
            drawIcon3D [_wpIcon, [1, 0.8, 0, 1], _wpPos, 1, 1, 0, "", 1, 0.04];

            // Render waypoint properties above the icon
            drawIcon3D ["", [1, 1, 1, 1], _wpPos vectorAdd [0, 0, 0.6], 0, 0, 0, format ["WP %1: %2", _forEachIndex + 1, _wpType], 1, 0.035, "RobotoCondensedBold", "center"];
            drawIcon3D ["", [0.85, 0.85, 0.85, 1], _wpPos vectorAdd [0, 0, 0.9], 0, 0, 0, format ["%1 | %2 | %3", _behavior, _combatMode, _formation], 1, 0.03, "RobotoCondensed", "center"];
            drawIcon3D ["", [0.7, 0.9, 1, 1], _wpPos vectorAdd [0, 0, 1.2], 0, 0, 0, format ["Speed: %1 | Radius: %2m", _speed, _radius], 1, 0.03, "RobotoCondensed", "center"];
        } forEach _wpModules;

        // If seek nearest player is configured at the end of waypoints
        if (_module getVariable [QGVAR(seek_end), true]) then {
            drawIcon3D ["", [1, 0.3, 0.3, 1], _prevPos vectorAdd [0, 0, 1.5], 0, 0, 0, "-> Seek Player", 1, 0.035, "RobotoCondensedBold", "center"];
        };

        // Retrieve and render active wave groups for this module
        private _groups = _module getVariable [QGVAR(groups), []];
        private _waveUnits = (_module getVariable [QGVAR(wave_units), []]) select { alive _x };
        {
            private _grp = group _x;
            if (!isNull _grp && {!(_grp in _groups)}) then {
                _groups pushBack _grp;
            };
        } forEach _waveUnits;

        if (_groups isEqualTo []) then {
            {
                if ((_x getVariable [QGVAR(wave_spawn), objNull]) isEqualTo _module) then {
                    _groups pushBackUnique _x;
                };
            } forEach allGroups;
        };

        _groups = _groups select { !isNull _x && {({alive _x} count (units _x)) > 0} };

        {
            private _group = _x;
            private _aliveUnits = (units _group) select { alive _x };
            if (_aliveUnits isEqualTo []) then { continue; };

            // Calculate geometric centroid of all group units
            private _xSum = 0;
            private _ySum = 0;
            private _zSum = 0;
            private _countUnits = count _aliveUnits;

            {
                private _pos = getPosATL _x;
                _xSum = _xSum + (_pos select 0);
                _ySum = _ySum + (_pos select 1);
                _zSum = _zSum + (_pos select 2);
            } forEach _aliveUnits;

            private _meanX = _xSum / _countUnits;
            private _meanY = _ySum / _countUnits;
            // Elevate 5 meters ATL relative to the group's units
            private _meanZ = ((_zSum / _countUnits) max 0) + 5;
            private _centroidAGL = ASLToAGL (ATLToASL [_meanX, _meanY, _meanZ]);

            private _grpSide = side _group;
            private _grpColor = switch (_grpSide) do {
                case west:        { [0.2, 0.5, 1, 1] };
                case east:        { [1, 0.2, 0.2, 1] };
                case resistance:  { [0.2, 0.9, 0.2, 1] };
                case civilian:    { [0.8, 0.4, 0.9, 1] };
                default           { [1, 1, 1, 1] };
            };
            private _grpIcon = switch (_grpSide) do {
                case east:        { "\a3\ui_f\data\map\markers\nato\o_inf.paa" };
                case west:        { "\a3\ui_f\data\map\markers\nato\b_inf.paa" };
                case resistance:  { "\a3\ui_f\data\map\markers\nato\n_inf.paa" };
                default           { "\a3\ui_f\data\map\markers\nato\c_unknown.paa" };
            };

            // Render group icon at elevated centroid
            drawIcon3D [
                _grpIcon,
                _grpColor,
                _centroidAGL,
                1.2,
                1.2,
                0,
                "",
                1,
                0.04
            ];

            // Display group status: quantity of units, behavior, combat mode, formation, speed
            drawIcon3D ["", [1, 1, 1, 1], _centroidAGL vectorAdd [0, 0, 0.5], 0, 0, 0, format ["Units: %1", _countUnits], 1, 0.038, "RobotoCondensedBold", "center"];
            drawIcon3D ["", [1, 0.9, 0.2, 1], _centroidAGL vectorAdd [0, 0, 0.85], 0, 0, 0, format ["%1 | %2", behaviour (leader _group), combatMode _group], 1, 0.035, "RobotoCondensedBold", "center"];
            drawIcon3D ["", [0.7, 0.9, 1, 1], _centroidAGL vectorAdd [0, 0, 1.2], 0, 0, 0, format ["%1 | %2", formation _group, speedMode _group], 1, 0.032, "RobotoCondensed", "center"];

            // Connect centroid to each individual unit in the group
            {
                drawLine3D [_centroidAGL, (getPosVisual _x) vectorAdd [0, 0, 1], _grpColor, 1];
            } forEach _aliveUnits;
        } forEach _groups;
    };
}, 0, []] call CBA_fnc_addPerFrameHandler;

missionNamespace setVariable [QGVAR(debug_PFH_handle), _handle];
#ifdef BTC_DEBUG_ENEMY_WAVES
[["%1: debug PFH started (handle: %2)", __FILE_NAME__, _handle], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif
systemChat "Enemy Waves Debug: ON";

_handle
