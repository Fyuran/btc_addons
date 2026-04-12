#define COMPONENT main
#include "\z\btc_json\addons\main\script_mod.hpp"

//#define BTC_DEBUG_JSON
//#define DISABLE_COMPILE_CACHE

#include "\z\btc_json\addons\main\script_macros.hpp"

#ifdef GVAR
	#undef GVAR
	#define GVAR(name) DOUBLES(PREFIX,name)
#endif
#ifdef FUNC
	#undef FUNC
	#define FUNC(fncName) TRIPLES(PREFIX,fnc,fncName)
#endif
