#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_getChunk

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_json_fnc_getChunk;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_ID", ""],
	["_size", 0]
];
if(_ID isEqualTo "") exitWith {
    [["%1: ID property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};
if(_size <= 0) exitWith {
    [["%1: size property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
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
