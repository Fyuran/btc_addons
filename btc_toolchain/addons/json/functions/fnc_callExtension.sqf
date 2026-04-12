#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_json_fnc_callExtension

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_json_fnc_callExtension;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
	["_request", createHashMap, [createHashMap]]
];

if(!("function" in _request)) exitWith {
    [["%1: function property missing", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _response = fromJSON("btc_ArmaToJSON" callExtension (toJSON _request));
private _error = _response getOrDefault["error", ""];
if(_error isNotEqualTo "") exitWith {
	[_error] call BIS_fnc_error;
	createHashMapFromArray[["error", _error]];
};

private _storageID = _response getOrDefault["ID", ""];
private _chunksSize = _response getOrDefault["size", 0];

//file is chunked, retrieve the pieces then compose the json
if((_storageID isNotEqualTo "") && {_chunksSize > 0}) then {
	_response = [_storageID, _chunksSize] call FUNC(getChunk);
};

_response
