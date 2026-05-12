#include "..\script_component.hpp"

params[
    ["_unit", objNull, [objNull]]
];
if(!alive _unit) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: _unit is not alive or is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    []
};
if(!local _unit) exitWith {
	[["%1: unit group is not local", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    0
};

private _objects = [_unit] call FUNC(nearestSortedObjects);
if(_objects isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: _objects is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    []
};

private _covers = [];
_objects apply {
    private _object = _x;
    private _positions = [_object] call FUNC(getCoverPositions_AGL);
    _positions = [_positions, [_unit], { _input0 distanceSqr _x }, "DESCEND"] call BIS_fnc_sortBy;
    _positions apply {
        private _position = _x;
        allPlayers apply {
            private _player = _x;
            if(([AGLToASL _position, _player] call FUNC(isPositionHidden_ASL))) then {
                _covers pushBackUnique [_object, _position];
            };
        };
    };
};
if(_covers isEqualTo []) exitWith {
    #ifdef BTC_DEBUG_STEALTH
	[["%1: no covers found", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
    []
};

private _group = group _unit;
private _cover_holders = _group getVariable[QGVAR(cover_holders), []];
private _cover = _covers#0;

private _hasFound = false;
_covers apply {
    private _c = _x;
    _c params ["_object", "_position"];
    _cover_holders apply {
        private _holder = _x;
        if((_position distance _holder) < 5) then { //if fails, go to next _position
            _hasFound = false;
            break;
        } else {
            _hasFound = true;
            _cover = _c;
        };
    };
    if(_hasFound) then {
        break;
    };
};

private _holder = createSimpleObject ["CBA_NamespaceDummy", AGLToASL (_cover#1)];
_holder setVariable[QGVAR(unit), _unit];
_unit setVariable[QGVAR(holder), _holder];
_cover_holders pushBack _holder;
_group setVariable[QGVAR(cover_holders), _cover_holders];

_cover
