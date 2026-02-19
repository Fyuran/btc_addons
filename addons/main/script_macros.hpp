#include "\x\cba\addons\main\script_macros_common.hpp"

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) FUNC(fncName) = compileScript [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)]
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call SLX_XEH_COMPILE_NEW
#endif

#define MAG_XX(a,b)   \
    class _xx_##a      \
    {                  \
        magazine = #a; \
        count = b;     \
    }
#define WEAP_XX(a,b) \
    class _xx_##a     \
    {                 \
        weapon = #a;  \
        count = b;    \
    }
#define ITEM_XX(a,b) \
    class _xx_##a     \
    {                 \
        name = #a;    \
        count = b;    \
    }

// BEGIN ACE3 reference macros

#define ACE_PREFIX ace

#define ACE_ADDON(component)        DOUBLES(ACE_PREFIX,component)

#define ACEGVAR(module,var)         TRIPLES(ACE_PREFIX,module,var)
#define QACEGVAR(module,var)        QUOTE(ACEGVAR(module,var))
#define QQACEGVAR(module,var)       QUOTE(QACEGVAR(module,var))

#define ACEFUNC(module,function)    TRIPLES(DOUBLES(ACE_PREFIX,module),fnc,function)
#define QACEFUNC(module,function)   QUOTE(ACEFUNC(module,function))

#define ACELSTRING(module,string)   QUOTE(TRIPLES(STR,DOUBLES(ACE_PREFIX,module),string))
#define ACELLSTRING(module,string)  localize ACELSTRING(module,string)
#define ACECSTRING(module,string)   QUOTE(TRIPLES($STR,DOUBLES(ACE_PREFIX,module),string))

#define ACEPATHTOF(component,path) \z\ace\addons\component\path
#define QACEPATHTOF(component,path) QUOTE(ACEPATHTOF(component,path))

#define CHAT 2
#define LOGS 4
#define REPORT 8
#define GLOBAL 16

#ifdef BTC_DEBUG_FULL
    #define BTC_DEBUG_AIPATHS
    #define BTC_DEBUG_C4BOOBY
    #define BTC_DEBUG_CANTEEN
    #define BTC_DEBUG_DEPLOYABLE_ANTENNA
    #define BTC_DEBUG_DIALOG
    #define BTC_DEBUG_ENEMY_WAVES
    #define BTC_DEBUG_INSIGNIA
    #define BTC_DEBUG_LIFT
    #define BTC_DEBUG_MAIN
    #define BTC_DEBUG_SNOWSTORM
    #define BTC_DEBUG_SUPPLY
    #define BTC_DEBUG_TOOLS
    #define BTC_DEBUG_WEIGHT_CALCULATOR
#endif
