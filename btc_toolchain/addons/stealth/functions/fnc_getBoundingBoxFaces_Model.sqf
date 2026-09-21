#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_stealth_fnc_getBoundingBoxFaces_Model

Description:
    Calculates the model-space coordinates of the 6 bounding box faces (Front, Back, Left, Right, Top, Bottom) of an object.

Parameters:
    _object: OBJECT

Returns:
    HASHMAP

Examples:
    (begin example)
        private _faces = [cursorObject] call btc_toolchain_stealth_fnc_getBoundingBoxFaces_Model;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_object", objNull, [objNull]]
];

if(isNull _object) exitWith {
	[["%1: _object is null", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    []
};

private _boundingBox = boundingBoxReal [_object, "FireGeometry"];
_boundingBox params["_boxMin", "_boxMax", "_radius"];
_boxMin params["_xMin", "_yMin", "_zMin"];
_boxMax params["_xMax", "_yMax", "_zMax"];

/*
Anti clockwise pattern
    3-----2
    :     :
    :     :
    0-----1
*/
private _boxMinTop = [_xMin, _yMin, _zMax];
createHashMapFromArray[
    ["Bottom",
        [       
            _boxMin, 
            [_xMax, _yMin, _zMin],
            [_xMax, _yMax, _zMin],
            [_xMin, _yMax, _zMin]
        ]
    ],
    ["Top",
        [
            [_xMin, _yMin, _zMax],
            [_xMax, _yMin, _zMax],
            [_xMax, _yMax, _zMax],
            [_xMin, _yMax, _zMax]
        ]
    ],
    ["Front",
        [
            _boxMin, 
            [_xMax, _yMin, _zMin],
            [_xMax, _yMin, _zMax],
            [_xMin, _yMin, _zMax]
        ]
    ],
    ["Right", 
        [
            [_xMax, _yMin, _zMin], 
            [_xMax, _yMax, _zMin],
            [_xMax, _yMax, _zMax],
            [_xMax, _yMin, _zMax]
        ]
    ],
    ["Left", 
        [
            [_xMin, _yMax, _zMin],
            [_xMin, _yMin, _zMin],
            [_xMin, _yMin, _zMax],
            [_xMin, _yMax, _zMax]
        ]
    ],
    ["Back",
        [
            [_xMax, _yMax, _zMin],
            [_xMin, _yMax, _zMin],
            [_xMin, _yMax, _zMax],
            [_xMax, _yMax, _zMax]
        ]
    ]
]
