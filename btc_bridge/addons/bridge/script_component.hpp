#define COMPONENT bridge
#include "script_mod.hpp"

//#define BTC_DEBUG_BRIDGE
//#define DISABLE_COMPILE_CACHE

#include "script_macros.hpp"

//REDEFINES
#define FUNC_S(fncName) DOUBLES(FUNC(fncName),server)
#define FUNC_O(fncName) DOUBLES(FUNC(fncName),owner)
#define FUNC_C(fncName) DOUBLES(FUNC(fncName),client)
#define QFUNC_S(fncName) QUOTE(FUNC_S(fncName))
#define QFUNC_O(fncName) QUOTE(FUNC_O(fncName))
#define QFUNC_C(fncName) QUOTE(FUNC_C(fncName))
#ifdef DISABLE_COMPILE_CACHE
    #define PREP_S(fncName) FUNC_S(fncName) = compileScript [QPATHTOF(functions\server\DOUBLES(fnc,fncName).sqf)]
    #define PREP_O(fncName) FUNC_O(fncName) = compileScript [QPATHTOF(functions\owner\DOUBLES(fnc,fncName).sqf)]
    #define PREP_C(fncName) FUNC_C(fncName) = compileScript [QPATHTOF(functions\client\DOUBLES(fnc,fncName).sqf)]
#else
	#define PREP_S(fncName) [QPATHTOF(functions\server\DOUBLES(fnc,fncName).sqf), QFUNC_S(fncName)] call SLX_XEH_COMPILE_NEW
    #define PREP_O(fncName) [QPATHTOF(functions\owner\DOUBLES(fnc,fncName).sqf), QFUNC_O(fncName)] call SLX_XEH_COMPILE_NEW
    #define PREP_C(fncName) [QPATHTOF(functions\client\DOUBLES(fnc,fncName).sqf), QFUNC_C(fncName)] call SLX_XEH_COMPILE_NEW
#endif

#define CAMERA_DISTANCE 20
#define SEGMENT_DISTANCE 6.55427
#define CAP_DISTANCE 6.45
#define DECO_OFFSET [0, -0.6, 0.3]

#define FRONT_OFFSET_MULTIPLIER 8
#define BRIDGE_DISPLAY 667700
#define CTRL_GRP 667701

#define BRIDGE_HEIGHT_LIMIT 1
#define BRIDGE_HEIGHT_STEP 0.5

#define RATE 0.0005
