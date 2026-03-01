#include "..\..\script_component.hpp"

if (!isDedicated && hasInterface) then {
    [{!isNull player}, {
        GVAR(test_c4_pos) = getPosATL test_c4;
        player setCaptive true;
        player allowDamage false;
        player addAction ["<t color='#009100'>Respawn Test C4</t>", {
            createVehicle["btc_c4booby_B_CargoNet_01_ammo_F", GVAR(test_c4_pos), [], 0, "NONE"];
        }, nil, 1.5, false];
    }] CBAFUNC(waitUntilAndExecute);
};
