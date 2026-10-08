#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_supply_fnc_list_grp2_keyUp

Description:
    Handles KeyUp on LIST_2 for shift modifier tracking.

Parameters:
    _grp2_list: CONTROL
    _key: NUMBER
    _shift: BOOLEAN
    _ctrl: BOOLEAN
    _alt: BOOLEAN

Returns:
    NOTHING

Author:
    =BTC= Fyuran
---------------------------------------------------------------------------- */
params ["_grp2_list", "_key", "_shift", "_ctrl", "_alt"];

if (_shift) then {
    GVAR(shift_modifier) = false;
};

