#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_canteen_fnc_Refill

Description:
	Will replenish unit's
	ACE_WaterBottle_Half
	ACE_WaterBottle_Nearly_Empty
	ACE_WaterBottle_Empty
	
	ACE_Canteen_Half
	ACE_Canteen_Nearly_Full
	ACE_Canteen_Nearly_Empty
	ACE_Canteen_Empty
Parameters:
	ACE_player: OBJECT

Returns:

Examples:
    (begin example)
		["ACE_Canteen"] call btc_canteen_fnc_Refill
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!params[
	["_item","",[""]]
]) exitWith {
	[["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};


[5,	_this,
{
	_args params ["_item"];
	ACE_player removeItem _item;
	_new_item = call {
		if(_item in ["ACE_WaterBottle_Half", "ACE_WaterBottle_Nearly_Empty", "ACE_WaterBottle_Empty"]) exitWith {"ACE_WaterBottle"};
		if(_item in ["ACE_Canteen_Half", "ACE_Canteen_Nearly_Full", "ACE_Canteen_Nearly_Empty", "ACE_Canteen_Empty"]) exitWith {"ACE_Canteen"};
		""
	};
	ACE_player addItem _new_item;
	private _targets = ACE_player nearEntities ["CAManBase", 20];
	["ace_medical_feedback_forceSay3D", [ACE_player, QGVAR(Refill_sound), 20], _targets] CBAFUNC(targetEvent);
	[format["%1 refilled.", getText(configFile >> "CfgWeapons" >> _item >> "DisplayName")], 2.5, ACE_player] call ace_common_fnc_displayTextStructured;

}, {}, "Refilling"] call ace_common_fnc_progressBar;
