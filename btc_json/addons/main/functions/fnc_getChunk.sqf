#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_json_json_fnc_getChunk

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_json_json_fnc_getChunk;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_ID", ""],
	["_size", 0]
];
if(_ID isEqualTo "") exitWith {
    ["'ID' property missing"] call BIS_fnc_error;
};
if(_size <= 0) exitWith {
    ["'size' property missing or equal to 0"] call BIS_fnc_error;
};

private _chunks = [];
private _requestChunk = createHashMapFromArray[
	["function", "getChunk"],
	["chunk", 0],
	["ID", _ID]
];
for "_i" from 0 to (_size - 1) do {
	_requestChunk set["chunk", _i];
	private _responseChunk = "btc_ArmaToJSON" callExtension (toJSON _requestChunk);
	_chunks pushBack _responseChunk;
};

fromJSON (_chunks joinString "")
