#include "\z\btc_json\addons\main\script_macros_common.hpp"
//REDEFINES
#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) FUNC(fncName) = compileScript [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)]
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call SLX_XEH_COMPILE_NEW
#endif

//debug
#define CHAT 2
#define LOGS 4
#define REPORT 8
#define GLOBAL 16

#ifdef BTC_DEBUG_FULL
    #define BTC_DEBUG_JSON
#endif
