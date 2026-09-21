#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_getAllSideCorpses

Description:
    Returns an array of dead bodies belonging to a specified side.

Parameters:
    _side: SIDE

Returns:
    ARRAY

Examples:
    (begin example)
        private _eastCorpses = [east] call btc_toolchain_stealth_fnc_getAllSideCorpses;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_side", east, [east]]
];

private _bodies = allDeadMen select {
    private _cfg = configOf _x;
    private _body_side = [getNumber(_cfg >> "side")] call BIS_fnc_sideType;
    _body_side isEqualTo _side
};

_bodies
