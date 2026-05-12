#include "..\script_component.hpp"

params[
    ["_side", east, [east]]
];

private _bodies = allDeadMen select {
    private _cfg = configOf _x;
    private _body_side = [getNumber(_cfg >> "side")] call BIS_fnc_sideType;
    _body_side isEqualTo _side
};

_bodies
