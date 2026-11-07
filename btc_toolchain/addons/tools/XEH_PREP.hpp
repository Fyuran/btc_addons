#include "script_component.hpp"

PREP(3DENNotification);
PREP(calculateBezier);
PREP(debug);
PREP(findSafePos);
PREP(getAllConfigsOf);
PREP(getCtrlsHashmap);
PREP(getVehicleWeaponsData);
PREP(getWeaponModes);
PREP(getWeaponType);
PREP(inheritsFromAny);
PREP(isCombatWeapon);
PREP(isInScreen);
PREP(redirectProjectile);
PREP(resolvePath);
PREP(spawnCrewedVehicle);
PREP(strToCfg);
PREP(timer);
PREP(uid);
PREP(vectorLerp);

CBAFUNC(debug2) = compileScript [QPATHTOF(functions\fnc_cba_debug2.sqf)];
