#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
Function: btc_canteen_fnc_Drink

Description:
   Drinking unit will regain max ACE Stamina

Parameters:
	ACE_player: OBJECT

Returns:

Examples:
    (begin example)
		["ACE_Canteen"] call btc_canteen_fnc_Drink
    (end)

Author:
    Fyuran

---------------------------------------------------------------------------- */

if(!params[
["_item","",[""]]
]) exitWith {    
	[["%1: bad params: %2", __FILE_NAME__, _this], REPORT, QCOMPONENT] call EFUNC(tools,debug);
};

private _targets = ACE_player nearEntities ["CAManBase", 20];
["ace_medical_feedback_forceSay3D", [ACE_player, QGVAR(Drink_sound), 20], _targets] CBAFUNC(targetEvent);

//animation
private _config = configFile >> "CfgWeapons" >> _item >> "acex_field_rations_consumeAnims";
private _stanceIndex = ["STAND", "CROUCH", "PRONE"] find stance ACE_player;
// Handle in vehicle when stance is UNDEFINED
if (!isNull objectParent ACE_player) then {_stanceIndex = 0};
private _consumeAnim = getArray (_config) param [_stanceIndex, "", [""]];
[ACE_player, _consumeAnim, 1] call ace_common_fnc_doAnimation;

[10, _this,
{
	_args params ["_item"];

	if(isNil "ace_advanced_fatigue_anreserve") exitWith {
    	[["%1: non existing ace_advanced_fatigue_anreserve, check if ACE is loaded", __FILE_NAME__], REPORT, QCOMPONENT] call EFUNC(tools,debug);
	};
	ace_advanced_fatigue_anreserve = 2300; //GVAR of ace_advanced_fatigue
	[format["You took a sip of %1.", getText(configFile >> "CfgWeapons" >> _item >> "DisplayName")], 2.5, ACE_player] call ace_common_fnc_displayTextStructured;
	ACE_player removeItem _item;
	_new_item = call {
		if(_item isEqualTo "ACE_WaterBottle") exitWith {"ACE_WaterBottle_Half"};
		if(_item isEqualTo "ACE_WaterBottle_Half") exitWith {"ACE_WaterBottle_Empty"};
		
		if(_item isEqualTo "ACE_Canteen") exitWith {"ACE_Canteen_Nearly_Full"};
		if(_item isEqualTo "ACE_Canteen_Nearly_Full") exitWith {"ACE_Canteen_Half"};
		if(_item isEqualTo "ACE_Canteen_Half") exitWith {"ACE_Canteen_Nearly_Empty"};
		if(_item isEqualTo "ACE_Canteen_Nearly_Empty") exitWith {"ACE_Canteen_Empty"};
		""
	};
	ACE_player addItem _new_item;
}, {}, "Drinking"] call ace_common_fnc_progressBar;
