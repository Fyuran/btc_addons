#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_calculateBezier

Description:
    Used to calculate a bezier path

Parameters:
    _startASL: OBJECT or ARRAY
    _controlPointASL: OBJECT or ARRAY
    _endASL: OBJECT or ARRAY
    _step: NUMBER
    _debug: BOOLEAN

Returns:
    ARRAY

Examples:
    (begin example)
        s
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */

params [
    ["_startASL", [0, 0, 0], [objNull, []], 3],
    ["_controlPointASL", [0, 0, 0], [objNull, []], 3],
    ["_endASL", [0, 0, 0], [objNull, []], 3],
    ["_step", 0.01, [123]],
    ["_debug", false, [true]]
];

if (_startASL isEqualType objNull) then {
    _startASL = getPosASL _startASL;
};
if (_startASL isEqualTo []) exitWith {
    [["%1: _startASL is empty", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
};

if (_controlPointASL isEqualType objNull) then {
    _controlPointASL = getPosASL _controlPointASL;
};
if (_controlPointASL isEqualTo []) exitWith {
    [["%1: _controlPointASL is empty", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
};

if (_endASL isEqualType objNull) then {
    _endASL = getPosASL _endASL;
};
if (_endASL isEqualTo []) exitWith {
    [["%1: _endASL is empty", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
};

if (_startASL in [_controlPointASL, _endASL]) exitWith {
    [["%1: one or more positions are the same: %2", __FILE_NAME__, [_startASL, _controlPointASL, _endASL]], REPORT, QCOMPONENT] call FUNC(debug);
};

private _startToControl = _controlPointASL vectorDiff _startASL;
private _controlToEnd = _endASL vectorDiff _controlPointASL;
private _time = 0;

private _points = [];

for "_time" from 0 to 1 step _step do {
    private _p0 = _startASL vectorAdd (_startToControl vectorMultiply _time);
    private _p1 = _controlPointASL vectorAdd (_controlToEnd vectorMultiply _time);

    //point at _time
    private _pointASL = vectorLinearConversion [0, 1, _time, _p0, _p1, true];

    // orientation from the tangent, zero roll
    private _dir = _p0 vectorFromTo _p1;
    private _right = vectorNormalized (_dir vectorCrossProduct [0, 0, 1]);
    private _up = _right vectorCrossProduct _dir;

    _points pushBack [_time, _pointASL, [_dir, _up]];
};

if (_debug) then {
    GVAR(bezierDebugHandle) = missionNamespace getVariable [QGVAR(bezierDebugHandle), -1];
    [GVAR(bezierDebugHandle)] call CBAFUNC(removePerFrameHandler);
    GVAR(bezierDebugHandle) = [{
        params ["_args", "_thisHandle"];
        _args params [
            ["_startASL", [0, 0, 0], [objNull, []], 3],
            ["_controlPointASL", [0, 0, 0], [objNull, []], 3],
            ["_endASL", [0, 0, 0], [objNull, []], 3],
            ["_points", [], [[]]]
        ];

        drawIcon3D [
            "",
            [0.2, 0.85, 0.2, 1],
            ASLToAGL _startASL,
            0,
            0,
            0,
            "•",
            1,
            0.05,
            "RobotoCondensedBold",
            "center"
        ];

        drawIcon3D [
            "",
            [0.2, 0.85, 0.2, 1],
            ASLToAGL _controlPointASL,
            0,
            0,
            0,
            "•",
            1,
            0.05,
            "RobotoCondensedBold",
            "center"
        ];

        drawIcon3D [
            "",
            [0.2, 0.85, 0.2, 1],
            ASLToAGL _endASL,
            0,
            0,
            0,
            "•",
            1,
            0.05,
            "RobotoCondensedBold",
            "center"
        ];
        
        private _i = 0;
        while {_i < ((count _points) - 1)} do {
            private _current = _points select _i;
            private _next = _points select (_i + 1);

            private _currentAGL = ASLToAGL (_current#1);
            private _nextAGL = ASLToAGL (_next#1);
    
            drawIcon3D [
                "",
                [1, 0.85, 0.2, 1],
                _currentAGL,
                0,
                0,
                0,
                "•",
                1,
                0.03,
                "RobotoCondensedBold",
                "center"
            ];
            drawLine3D [_currentAGL, _nextAGL, [1, 0.2, 0.2, 0.8]];
            drawIcon3D [
                "",
                [1, 0.85, 0.2, 1],
                _nextAGL,
                0,
                0,
                0,
                "•",
                1,
                0.03,
                "RobotoCondensedBold",
                "center"
            ];

            _i = _i + 1;
        };
    }, 0, [_startASL, _controlPointASL, _endASL, _points]] call CBAFUNC(addPerFrameHandler);
};


_points
