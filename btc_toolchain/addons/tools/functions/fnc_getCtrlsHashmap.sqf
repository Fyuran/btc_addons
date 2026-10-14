#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_toolchain_tools_fnc_getCtrlsHashmap

Description:
    Retrieves all controls from control or display then stores them into a hashmap, mostly useful when controls have idc -1.
    If duplicate class names are encountered, keys are automatically suffixed with "_2", "_3", etc.

Parameters:
    _root: CONTROL or DISPLAY

Returns:
    HASHMAP

Examples:
    (begin example)
        private _ctrls = [_ctrlGrp] call btc_toolchain_tools_fnc_getCtrlsHashmap;
    (end)

Author:
    =BTC= Fyuran

---------------------------------------------------------------------------- */
params [
    ["_root", controlNull, [controlNull, displayNull]]
];
disableSerialization;

if (isNull _root) exitWith {
    [["%1: _root is null", __FILE_NAME__], REPORT, QCOMPONENT] call FUNC(debug);
    createHashMap
};

private _controls = createHashMap;

(allControls _root) apply {
    private _control = _x;
    private _class = ctrlClassName _control;
    if (_class isEqualTo "") then {
        _class = format ["Control_%1", ctrlIDC _control];
    };

    private _key = _class;
    if (_key in _controls) then {
        private _index = 2;
        private _candidate = format ["%1_%2", _class, _index];
        while {_candidate in _controls} do {
            _index = _index + 1;
            _candidate = format ["%1_%2", _class, _index];
        };
        _key = _candidate;
    };

    [["%1: found [%2, %3]", __FILE_NAME__, _key, _control], LOGS, QCOMPONENT] call FUNC(debug);

    _controls set [_key, _control];
};

_controls
