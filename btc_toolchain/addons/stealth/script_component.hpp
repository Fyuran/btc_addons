#define COMPONENT stealth
#include "\z\btc_toolchain\addons\main\script_mod.hpp"

//#define BTC_DEBUG_STEALTH
//#define DISABLE_COMPILE_CACHE

#include "\z\btc_toolchain\addons\main\script_macros.hpp"

#define MIN_DIS 0
#define MIN_RATE 0.25
#define MAX_RATE 1
#define TICK_RATE 0.02
#define ALARM_DISTANCE 300
#define THREAT_DISTANCE 50
#define THREAT_FACTOR 5
#define INTRUDER 1
#define BODY 2
#define IS_UNCONSCIOUS _unit getVariable ["ACE_isUnconscious", false]

#define EYE_OFFSET [0.154297,0.381836,1.51448]
