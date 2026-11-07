#include "..\..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_cas_fnc_list_initVehicleData

Description:
    Populates LIST_1 (weapons) and optionally cascades to LIST_2 (modes) based on the specified vehicle class.

Parameters:
    _class: STRING - Vehicle class
    _selectDefault: BOOLEAN - If true, select index 0 in LIST_1 and populate LIST_2 (optional, default: true)

Returns:
    NOTHING

Examples:
    (begin example)
        ["B_Plane_CAS_01_dynamicLoadout_F"] call btc_toolchain_cas_fnc_list_initVehicleData;
        ["B_Plane_CAS_01_dynamicLoadout_F", _grp, false] call btc_toolchain_cas_fnc_list_initVehicleData;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_class", "", [""]]
];
disableSerialization;

if (_class isEqualTo "") exitWith {
    #ifdef BTC_DEBUG_CAS
    [["%1: _class is empty", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
    #endif
};

private _vehicleDataGrp = uiNamespace getVariable [QGVAR(vehicleDataGrp), controlNull];

//second attempt is a charm as they say
if (isNull _vehicleDataGrp) then {
    private _editDisplay = findDisplay IDD_DISPLAY3DENEDITATTRIBUTES;
    if (!isNull _editDisplay) then {
        private _attributesGrp = _editDisplay displayCtrl IDC_DISPLAY3DENEDITATTRIBUTES_CATEGORIES;
        _vehicleDataGrp = _attributesGrp controlsGroupCtrl VEHICLE_DATA;
    };
};

//none found, abort
if (isNull _vehicleDataGrp) exitWith {};

#ifdef BTC_DEBUG_CAS
[["%1: executing list_initVehicleData: class=%2, grp=%3", __FILE_NAME__, _class, _vehicleDataGrp], LOGS, QCOMPONENT] call EFUNC(tools,debug);
#endif

private _grp1ListGrp = _vehicleDataGrp controlsGroupCtrl LIST_1;
private _grp1List = _grp1ListGrp controlsGroupCtrl IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
lbClear _grp1List;

private _data = [_class] call EFUNC(tools,getVehicleWeaponsData);
if (_data isEqualTo []) exitWith {};

_data apply {
    private _wpnClass = _x getOrDefault ["class", ""];
    private _displayName = _x getOrDefault ["displayName", ""];
    private _icon = _x getOrDefault ["icon", ""];

    if (_wpnClass isEqualTo "" || {_displayName isEqualTo ""}) then {
        continue;
    };

    private _row = _grp1List lbAdd _displayName;
    _grp1List lbSetPicture [_row, _icon];
    _grp1List lbSetData [_row, _wpnClass];
    _grp1List lbSetTooltip [_row, _wpnClass];
};

lbSort _grp1List;
