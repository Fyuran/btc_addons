#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_uid

Description:
    Generates a unique random alphanumeric identifier string based on tickTime and random characters.

Parameters:
    _seed: NUMBER

Returns:
    STRING

Examples:
    (begin example)
        private _uid = [12345] call btc_toolchain_tools_fnc_uid;
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
