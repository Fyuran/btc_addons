#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_isInScreen

Description:
    Checks if a world position is visibile in 3D viewport

Parameters:
    _posAGL: ARRAY

Returns:
    BOOLEAN - True if in viewport else false

Examples:
    (begin example)
        private _isPosVisible = [[0, 0, 0]] call btc_toolchain_tools_fnc_isInScreen;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_posAGL", [0, 0, 0], [[], objNull], [2, 3]]
];

if (_posAGL isEqualType objNull) then {
    _posAGL = getPosVisual _posAGL;
};
private _screenPos = worldToScreen _posAGL;

_screenPos isNotEqualTo []
