#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_tools_fnc_uid

Description:
    Generates a random UID

Parameters:
    _seed: a random seed to be used for the UID

Returns:

Examples:
    (begin example)
	[] call btc_tools_fnc_uid;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_seed", str(diag_tickTime), []]
];
private _tick = (str _seed) + "-";
private _chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" splitString "";
private _suffix = "";

for "_i" from 1 to 12 do {
	_suffix = _suffix + selectRandom _chars;
};

private _uniqueID = _tick + _suffix;
_uniqueID
