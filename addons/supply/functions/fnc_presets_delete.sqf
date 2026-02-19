#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_supply_fnc_presets_delete

Description:

Parameters:

Returns:

Examples:
    (begin example)
        [] call btc_supply_fnc_presets_delete;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_delete", controlNull, [controlNull]]
];
disableSerialization;

private _display = ctrlParent _delete;
if(isNull _display) exitWith {
	[["% 1: _display is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};

private _list = _display displayCtrl PRESETS_LIST;
if(isNull _list) exitWith {
	[["% 1: _list is null", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};
private _lbCurSel = lbCurSel _list;
if(_lbCurSel < 0) exitWith {
	[["Nothing is selected", __FILE_NAME__], REPORT, "supply"] call EFUNC(tools,debug);
};
_savedPresets = profileNamespace getVariable[QGVAR(savedPresets), createHashMap];
_savedPresets deleteAt (_list lbText _lbCurSel);
#ifdef BTC_DEBUG_SUPPLY
[["% 1: removing save: %2", __FILE_NAME__, _list lbText _lbCurSel], CHAT, "supply"] call EFUNC(tools,debug);
#endif
_list lbDelete _lbCurSel;
profileNamespace setVariable[QGVAR(savedPresets), _savedPresets];
