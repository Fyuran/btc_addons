#define COMPONENT main
#include "\z\btc_factions\addons\main\script_mod.hpp"

//#define BTC_DEBUG_FACTIONS
//#define DISABLE_COMPILE_CACHE

#include "\z\btc_factions\addons\main\script_macros.hpp"

#ifdef GVAR
	#undef GVAR
	#define GVAR(name) DOUBLES(btc_factions,name)
#endif
#ifdef FUNC
	#undef FUNC
	#define FUNC(fncName) DOUBLES(btc_factions_fnc,fncName)
#endif
