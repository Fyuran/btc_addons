#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_uid

Description:
    Generates a random UID

Parameters:
    _seed: a random seed to be used for the UID

Returns:

Examples:
    (begin example)
	[] call btc_toolchain_tools_fnc_uid;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_seed", round diag_tickTime, []]
];

private _chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" splitString "";
private _suffix = "";

for "_i" from 1 to 12 do {
	_suffix = _suffix + selectRandom _chars;
};

private _uniqueID = format["%1-%2", _seed, _suffix];
_uniqueID
