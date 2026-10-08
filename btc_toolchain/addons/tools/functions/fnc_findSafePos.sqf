#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_findSafePos

Description:
    Finds a safe position near a starting coordinate for a given type or object.
    Prefers road positions when dealing with land vehicle types/classes.

Parameters:
    _pos: ARRAY, OBJECT, STRING or LOCATION - Center position to search around
    _type: STRING or OBJECT - Classname or object to find a safe position for (optional, default "")
    _maxDist: NUMBER - Maximum search distance in meters (optional, default 100)
    _minDist: NUMBER - Minimum search distance in meters (optional, default 0)
    _preferRoads: BOOLEAN - Prefer road positions when applicable (optional, default true)

Returns:
    ARRAY - Safe 3D position [x, y, z]

Examples:
    (begin example)
        private _pos = [_logic, "B_MRAP_01_F"] call btc_toolchain_tools_fnc_findSafePos;
        private _pos = [player, "B_Soldier_F", 50] call btc_toolchain_tools_fnc_findSafePos;
        private _pos = [getPos player, cursorObject, 100, 10] call btc_toolchain_tools_fnc_findSafePos;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_pos", [0, 0, 0], [[], objNull, "", locationNull], [2, 3]],
    ["_type", "", ["", objNull]],
    ["_maxDist", 100, [0]],
    ["_minDist", 0, [0]],
    ["_preferRoads", true, [true]]
];

if (_pos isEqualType objNull && {isNull _pos}) exitWith {
    #ifdef BTC_DEBUG_TOOLS
    [["%1: null object passed as position", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
    #endif
    [0, 0, 0]
};

private _center = switch (true) do {
    case (_pos isEqualType objNull): { getPosATL _pos };
    case (_pos isEqualType ""): { getMarkerPos _pos };
    case (_pos isEqualType locationNull): { locationPosition _pos };
    case (_pos isEqualType []): {
        if (count _pos >= 3) then {
            + _pos
        } else {
            [_pos select 0, _pos select 1, 0]
        }
    };
    default { [0, 0, 0] };
};

private _class = if (_type isEqualType objNull) then {
    if (isNull _type) then {""} else {typeOf _type}
} else {
    _type
};

private _isClassValid = (_class isNotEqualTo "") && {isClass (configFile >> "CfgVehicles" >> _class)};

// Check if land vehicle (Car, Tank, Motorcycle, etc.)
private _isLandVehicle = if (_isClassValid) then {
    ([_class, ["LandVehicle"]] call FUNC(inheritsFromAny)) &&
    {!([_class, ["StaticWeapon"]] call FUNC(inheritsFromAny))}
} else {
    false
};

private _isShip = if (_isClassValid) then {
    [_class, ["Ship"]] call FUNC(inheritsFromAny)
} else {
    false
};

private _isAir = if (_isClassValid) then {
    [_class, ["Air"]] call FUNC(inheritsFromAny)
} else {
    false
};

// Clearance radius calculation
private _size = if (_isClassValid) then {
    sizeOf _class
} else {
    0
};

private _clearRadius = switch (true) do {
    case (_size > 0): { ((_size / 2) max 2) };
    case (_isLandVehicle): { 4 };
    case (_isAir): { 10 };
    default { 2 };
};

_maxDist = _maxDist max (_clearRadius * 2);

private _waterMode = switch (true) do {
    case (_isShip): { 2 }; // Must be in water
    default { 0 };         // Cannot be in water
};

private _foundPos = [];

// 1. Check roads if preferred
if (_preferRoads && {_isLandVehicle || _class isEqualTo ""}) then {
    private _nearRoads = _center nearRoads _maxDist;
    if (_minDist > 0) then {
        _nearRoads = _nearRoads select {(_x distance2D _center) >= _minDist};
    };

    if (_nearRoads isNotEqualTo []) then {
        // Sort roads by distance to center ascending
        _nearRoads = [_nearRoads, [_center], {_x distance2D _input0}, "ASCEND"] call BIS_fnc_sortBy;

        private _roadIndex = _nearRoads findIf {
            private _roadPos = getPosATL _x;
            ((_roadPos nearEntities [["AllVehicles"], _clearRadius]) isEqualTo []) &&
            {(nearestObjects [_roadPos, ["Wreck_Base"], _clearRadius]) isEqualTo []} &&
            {(nearestTerrainObjects [_roadPos, ["TREE", "ROCK"], 2]) isEqualTo []}
        };

        if (_roadIndex isNotEqualTo -1) then {
            private _selectedRoad = _nearRoads select _roadIndex;
            _foundPos = getPosATL _selectedRoad;
        };
    };
};

if (_foundPos isNotEqualTo []) exitWith {
    #ifdef BTC_DEBUG_TOOLS
    [["%1: found safe road position %2 for %3", __FILE_NAME__, _foundPos, _class], LOGS, QCOMPONENT] call FUNC(debug);
    #endif
    _foundPos
};

// 2. Terrain search fallback
private _maxGrad = switch (true) do {
    case (_isLandVehicle): { 0.3 };
    case (_isAir): { 0.15 };
    default { 0.5 };
};

private _safePos = [];
for "_i" from 1 to 10 do {
    private _candidate = [_center, _minDist, _maxDist, _clearRadius, _waterMode, _maxGrad, 0, [], []] call BIS_fnc_findSafePos;
    if (_candidate isNotEqualTo []) then {
        private _candidate3D = [_candidate select 0, _candidate select 1, 0];
        if ((_candidate3D nearEntities [["AllVehicles"], _clearRadius]) isEqualTo [] &&
            {(nearestObjects [_candidate3D, ["Wreck_Base", "House"], _clearRadius]) isEqualTo []}) exitWith {
            _safePos = _candidate3D;
        };
    };
};

if (_safePos isEqualTo []) then {
    private _fallback = [_center, _minDist, _maxDist, _clearRadius, _waterMode, _maxGrad, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
    if (_fallback isNotEqualTo []) then {
        _safePos = [_fallback select 0, _fallback select 1, 0];
    } else {
        _safePos = +_center;
    };
};

#ifdef BTC_DEBUG_TOOLS
[["%1: found safe terrain position %2 for %3", __FILE_NAME__, _safePos, _class], LOGS, QCOMPONENT] call FUNC(debug);
#endif

_safePos

