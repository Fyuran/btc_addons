#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_snowstorm_fnc_postprocess_clients

Description:
    Handles color correction.

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_snowstorm_fnc_postprocess_clients;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
if(!hasInterface) exitWith {
	#ifdef BTC_DEBUG_SNOWSTORM
    [["%1: attempted to exec on a client with no interface", __FILE__], 2, "snowstorm"] call EFUNC(tools,debug);
	#endif
};

if(!GVAR(enable_ppe)) exitWith {
	#ifdef BTC_DEBUG_SNOWSTORM
    [["%1: client has disabled ppe", __FILE__], 2, "snowstorm"] call EFUNC(tools,debug);
	#endif
};
GVAR(color_correction) = ppEffectCreate["ColorCorrections", 1500];
GVAR(color_correction) ppEffectEnable true;
GVAR(color_correction) ppEffectAdjust [
	1,		  // Brightness
	1.05,	   // Contrast
	-0.01,	  // Offset
	[0.0, 0.0, 0.1, 0.1],	  // [R,G,B,A] Color Overlay (Blue tint)
	[0.8, 0.8, 1.0, 0.6],	  // [R,G,B,A] Color Transformation
	[0.3, 0.3, 0.3, 0.05]	  // [R,G,B,A] Color Color (Desaturation)
];
GVAR(color_correction) ppEffectCommit 0;
