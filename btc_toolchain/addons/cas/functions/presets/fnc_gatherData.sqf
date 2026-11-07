#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_presets_gatherData

Description:
    Gathers current cas dialog attributes into a HashMap for preset saving.

Parameters:
    None

Returns:
    HASHMAP - Preset attribute data

Examples:
    (begin example)
        _presetData = [] call btc_toolchain_cas_fnc_presets_gatherData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
#ifdef BTC_DEBUG_CAS
[["%1: saving preset %2", __FILE_NAME__, createHashMapFromArray [], LOGS, QCOMPONENT]] call EFUNC(tools,debug);
#endif

createHashMap
