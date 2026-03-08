// Register a simple keypress to an action
#include "\a3\ui_f\hpp\definedikcodes.inc"

if (!isDedicated && hasInterface) then {
    [{!isNull player}, {
        player setCaptive true;
        player allowDamage false;

        Camrunning = true; // set to false to stop the camera
        player addAction ["<t color='#FF0000'>Hide AI Paths</t>", {call btc_toolchain_aipaths_fnc_hideObjects}, nil, 1.5, false];
        player addAction ["<t color='#00FF00'>Show AI Paths</t>", {call btc_toolchain_aipaths_fnc_unhideObjects}, nil, 1.5, false];

    }] call CBA_fnc_waitUntilAndExecute;
};
