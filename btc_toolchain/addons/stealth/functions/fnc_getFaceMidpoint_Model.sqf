#include "..\script_component.hpp"

params [
    ["_face", [], [[]], 4]
];

_face params[
    ["_p1", [], [[]], 3],
    ["_p2", [], [[]], 3],
    ["_p3", [], [[]], 3],
    ["_p4", [], [[]], 3]
];

[
    ((_p1 select 0) + (_p2 select 0) + (_p3 select 0) + (_p4 select 0)) / 4,
    ((_p1 select 1) + (_p2 select 1) + (_p3 select 1) + (_p4 select 1)) / 4,
    ((_p1 select 2) + (_p2 select 2) + (_p3 select 2) + (_p4 select 2)) / 4
]
