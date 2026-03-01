#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_snowstorm_fnc_initSlider

Description:
    Initiates snowfall.

Parameters:

Returns:

Examples:
    (begin example)
	[] call btc_toolchain_snowstorm_fnc_initSlider;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params[
    ["_args", ctrlNull, [controlNull, []], 2],
    ["_value", 0, [123]]
];
_args params[
    ["_ctrlGroup", controlNull, [controlNull]],
    ["_cfg", configNull, [configNull]]
];
if(!isServer) exitWith {};
private _ctrlEdit = _ctrlGroup controlsGroupCtrl 50;
private _ctrlTitle = _ctrlGroup controlsGroupCtrl 51;
private _ctrlSlider = _ctrlGroup controlsGroupCtrl 52;

#ifdef BTC_DEBUG_SNOWSTORM
[["%1: initializing module slider %2", __FILE_NAME__, [_ctrlGroup, _ctrlSlider, _ctrlEdit, _ctrlTitle]], 3, QCOMPONENT] call EFUNC(tools,debug);
[["%1: _this analysis: _args: %2, _value: %3", __FILE_NAME__, _args, _value], 3, QCOMPONENT] call EFUNC(tools,debug);
#endif

_ctrlEdit ctrlSetText (str _value);
_ctrlSlider sliderSetPosition _value;

_ctrlSlider ctrlAddEventHandler ["SliderPosChanged", {
    params ["_ctrlSlider", "_newValue"];
    _ctrlGroup = ctrlParentControlsGroup _ctrlSlider;
    _ctrlEdit = _ctrlGroup controlsGroupCtrl 50;
    _ctrlEdit ctrlSetText (str _newValue);

}];
