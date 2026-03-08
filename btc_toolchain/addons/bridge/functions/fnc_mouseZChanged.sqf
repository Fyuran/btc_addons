    
#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_bridge_mouseZChanged

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_toolchain_bridge_mouseZChanged;
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */
params [
	["_scroll", 0, [123]]
];
private _vector = GVAR(camera_vector);
if(_scroll < 0) then {
	_vector = _vector vectorMultiply 1.1;
} else {
	_vector = _vector vectorMultiply 0.9;        
};

private _distance = (((vectorMagnitude _vector) min 40) max 5);        
if((_distance >= 40) or (_distance <= 5)) exitWith {};

GVAR(camera_vector) = _vector;
GVAR(camera_distance) = _distance;
GVAR(camera) camSetRelPos GVAR(camera_vector);
GVAR(camera) camCommit 0.1;
