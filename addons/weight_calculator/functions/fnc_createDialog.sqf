#include "..\script_component.hpp"
/* ----------------------------------------------------------------------------
	Function: btc_toolchain_weight_calculator_createDialog
	
	Description:
	    Opens dialog and populates list
	
	Parameters:
	
	Returns:
	
	Examples:
	    (begin example)
	        [] call btc_toolchain_weight_calculator_createDialog;
	    (end)
	
	Author:
	    Fyuran
	
---------------------------------------------------------------------------- */

#define _WEAPONCFG (_cfg >> 'CfgWeapons' >> _class)
#define _WEAPONDATA(ARG) (_WEAPONCFG##>>ARG)

#define _MAGAZINECFG (_cfg >> 'CfgMagazines' >> _class)
#define _MAGAZINEDATA(ARG) (_MAGAZINECFG##>>ARG)

#define _CONTAINERCFG (_cfg >> 'CfgVehicles' >> _class)
#define _CONTAINERDATA(ARG) (_CONTAINERCFG##>>ARG)

disableSerialization;

private _dialog = createDialog["btc_toolchain_weight_calculator"];
private _listNBox = _dialog displayCtrl 1500;
private _kgCounter = _dialog displayCtrl 1002;

private _array = [];
private _loadout = [
	primaryWeapon player,
	primaryWeaponMagazine player,
	primaryWeaponItems player,
	secondaryWeapon player,
	secondaryWeaponMagazine player,
	secondaryWeaponItems player,
	handgunWeapon player,
	handgunMagazine player,
	handgunItems player,
	magazines player,
	items player,
	vest player,
	backpack player,
	uniform player,
	assignedItems[player, true, true]
];
[_loadout, _array] call FUNC(parseClasses);

_array = _array call BIS_fnc_consolidateArray;



// mass / 22 = Kilograms
private _cfg = configFile;
private _summedKgs = 0;

{
	_x params[
		["_class", "", [""]], 
		["_count", 0, [123]]	
	];
	
	private _kg = 0;
	private _totalKg = 0;
	private _name = "";
	private _picture = "";
	
	switch(true) do {
	  case (isNumber _WEAPONDATA("ItemInfo" >> "mass")): {
		_picture = getText _WEAPONDATA("picture");
		_name = getText _WEAPONDATA("displayName");
		_kg = (getNumber _WEAPONDATA("ItemInfo" >> "mass")) / 22;
	  };
	  case (isNumber _WEAPONDATA("WeaponSlotsInfo" >> "mass")): {
		_picture = getText _WEAPONDATA("picture");
		_name = getText _WEAPONDATA("displayName");
		_kg = (getNumber _WEAPONDATA("WeaponSlotsInfo" >> "mass")) / 22;
	  };
	  case (isNumber _MAGAZINEDATA("mass")): {
		_picture = getText _MAGAZINEDATA("picture");
		_name = getText _MAGAZINEDATA("displayName");
		_kg = (getNumber _MAGAZINEDATA("mass")) / 22;
	  };
	  case (isNumber _CONTAINERDATA("mass")): {
		_picture = getText _CONTAINERDATA("picture");
		_name = getText _CONTAINERDATA("displayName");
		_kg = (getNumber _CONTAINERDATA("mass")) / 22;  
	  }; 
	};
	
	_totalKg = _kg * _count;
	_array set[_forEachIndex, _x + [_picture, _name, _kg, _totalKg]];
	
	_summedKgs = _summedKgs + _totalKg;
	
}forEach _array;


_array = [_array, [], { _x#5 }, "DESCEND"] call BIS_fnc_sortBy; //sort by KG

for "_i" from 0 to (count (_array#0)) do {
	_listNBox lnbAddColumn _i;
}; //add as many columns as required

{
	_x params[
		["_class", "", [""]], 
		["_count", 0, [123]],
		["_picture", "", [""]],
		["_name", "",[""]],
		["_kg", 0, [123]],
		["_totalKg", 0, [123]]	
	];

	_listNBox lnbAddRow["	" + _name, str _count, (_kg toFixed 2) + "kg", (_totalKg toFixed 2) + "kg"];
	_listNBox lnbSetPicture[[_forEachIndex+1, 0], _picture];
}forEach _array;

_kgCounter ctrlSetText (format["All: %1kg", _summedKgs toFixed 2]);
