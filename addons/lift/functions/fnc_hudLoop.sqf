#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_lift_fnc_hudLoop

Description:
    Performs HUD functions such as crosshair adjustment, cargo icon etc.

Parameters:
    _ui - [Array]
    _PFH_id - [Number]

Returns:

Examples:
    (begin example)
        _result = [] call btc_toolchain_lift_fnc_hudLoop;
    (end)

Author:
    Giallustio, Fyuran

---------------------------------------------------------------------------- */

params [
    ["_ui", [], [[]]],
    ["_PFH_id", 0, [0]]
];
_ui params ["_arrow_up", "_arrow_down", "_complete", "_incomplete", "_crosshair", "_obj_pic", "_arrow", "_obj_name", "_obj_alt"];

disableSerialization;

if !((alive player && {!isNull objectParent player}) && GVAR(hud)) then {
    [_PFH_id] call CBAFUNC(removePerFrameHandler);
    939996 cutText ["", "PLAIN"];
};

private _chopper = vehicle player;
private _array = [_chopper] call FUNC(getLiftable);
private _cargo_array = nearestObjects [_chopper, _array, 30];
if (_array isEqualTo []) then {_cargo_array = [];};
_cargo_array = _cargo_array - [_chopper];
_cargo_array = _cargo_array select {!(
    _x isKindOf "ACE_friesBase" OR
    _x isKindOf "ace_fastroping_helper"
)};

_cargo_array params [["_cargo", objNull]];
private _can_lift = _array findIf {_cargo isKindOf _x} != -1;

if (!isNull _cargo) then {
    _cargo_pos = getPosATL _cargo;
    (_chopper worldToModel _cargo_pos) params ["_cargo_x", "_cargo_y"];
    _cargo_z = ((getPosATL _chopper) select 2) - (_cargo_pos select 2);
    _crosshair ctrlShow true;
    private _hud_x = _cargo_x / 100;
    private _hud_y = - _cargo_y / 100;
    private _hud_x_1 = (BTC_LIFT_HUD_X + _hud_x) * safeZoneW + safeZoneX;
    private _hud_y_1 = (BTC_LIFT_HUD_Y + _hud_y) * safeZoneH + safeZoneY;
    _crosshair ctrlSetPosition [_hud_x_1, _hud_y_1];
    _crosshair ctrlCommit 0;
    private _pic_cargo = "";
    private _cfgVehicles_cargo = configOf _cargo;
    if (_cargo isKindOf "LandVehicle") then {
        _pic_cargo = getText (_cfgVehicles_cargo >> "picture");
    };
    private _name_cargo = getText (_cfgVehicles_cargo >> "displayName");
    _obj_pic ctrlSetText _pic_cargo;
    _obj_name ctrlSetText _name_cargo;
    if (GVAR(lifted)) then {
        _obj_alt ctrlSetText (format ["%1 m", (round((getPos _cargo select 2) * 10))/10]);
        _crosshair ctrlSetTextColor [0, 1, 0, 1];
        _obj_pic ctrlSetTextColor [0, 1, 0, 1];
    };

    if ((abs _cargo_z) > (BTC_LIFT_MAX_H + 3)) then {
        _arrow ctrlSetText _arrow_down;
        _arrow ctrlSetTextColor [1, 0, 0, 1];
    } else {
        if ((abs _cargo_z) > BTC_LIFT_MAX_H) then {
            _arrow ctrlSetText _arrow_down;
            _arrow ctrlSetTextColor [1, 1, 0, 1];
        };
    };
    if ((abs _cargo_z) < (BTC_LIFT_MIN_H - 3)) then {
        _arrow ctrlSetText _arrow_up;
        _arrow ctrlSetTextColor [1, 0, 0, 1];
    } else {
        if ((abs _cargo_z) < BTC_LIFT_MIN_H) then {
            _arrow ctrlSetText _arrow_up;
            _arrow ctrlSetTextColor [1, 1, 0, 1];
        };
    };
    if ((abs _cargo_z) > BTC_LIFT_MIN_H && (abs _cargo_z) < BTC_LIFT_MAX_H) then {
        _arrow ctrlSetText _complete;
        _arrow ctrlSetTextColor [0, 1, 0, 1];
    };
    if !(_can_lift) then {
        _arrow ctrlSetText _incomplete;
        _arrow ctrlSetTextColor [1, 0, 0, 1];
    };
} else {
    _crosshair ctrlShow false;
    _obj_pic ctrlSetText "";
    _obj_pic ctrlSetTextColor [1, 0, 0, 1];
    _obj_pic ctrlSetTextColor [1, 1, 1, 1];
    _obj_name ctrlSetText "";
    _arrow ctrlSetText "";
};
