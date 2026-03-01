/*
// weapon types
#define TYPE_WEAPON_PRIMARY 1
#define TYPE_WEAPON_HANDGUN 2
#define TYPE_WEAPON_SECONDARY 4
// magazine types
#define TYPE_MAGAZINE_HANDGUN_AND_GL 16 // mainly
#define TYPE_MAGAZINE_PRIMARY_AND_THROW 256
#define TYPE_MAGAZINE_SECONDARY_AND_PUT 512 // mainly
#define TYPE_MAGAZINE_MISSILE 768
// more types
#define TYPE_BINOCULAR_AND_NVG 4096
#define TYPE_WEAPON_VEHICLE 65536
#define TYPE_ITEM 131072
// item types
#define TYPE_DEFAULT 0
#define TYPE_MUZZLE 101
#define TYPE_OPTICS 201
#define TYPE_FLASHLIGHT 301
#define TYPE_BIPOD 302
#define TYPE_FIRST_AID_KIT 401
#define TYPE_FINS 501 // not implemented
#define TYPE_BREATHING_BOMB 601 // not implemented
#define TYPE_NVG 602
#define TYPE_GOGGLE 603
#define TYPE_SCUBA 604 // not implemented
#define TYPE_HEADGEAR 605
#define TYPE_FACTOR 607
#define TYPE_RADIO 611
#define TYPE_HMD 616
#define TYPE_BINOCULAR 617
#define TYPE_MEDIKIT 619
#define TYPE_TOOLKIT 620
#define TYPE_UAV_TERMINAL 621
#define TYPE_VEST 701
#define TYPE_UNIFORM 801
#define TYPE_BACKPACK 901
*/
#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Canteen";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {"ACE_Canteen_Nearly_Empty_Item","ACE_Canteen_Nearly_Full_Item"};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {"ACE_Canteen_Nearly_Empty","ACE_Canteen_Nearly_Full"};
		requiredAddons[] = {"btc_toolchain_main"};
		VERSION_CONFIG;
	};
};

class CfgWeapons {
    class CBA_MiscItem_ItemInfo;
	class ACE_ItemCore;
	
	class ACE_Canteen: ACE_ItemCore {
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 5;
        };
    };
	class ACE_Canteen_Nearly_Full: ACE_Canteen {
        displayName = "Canteen (Nearly-Full)";
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 4;
        };
	};
	class ACE_Canteen_Half: ACE_Canteen {
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 3;
        };
    };

	class ACE_Canteen_Nearly_Empty: ACE_Canteen {
		displayName = "Canteen (Nearly-empty)";
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 2;
        };
	};
};

class CfgVehicles {
	class ACE_Canteen_Item;
	class ACE_Canteen_Nearly_Full_Item: ACE_Canteen_Item {
        displayName = "Canteen (Nearly-Full)";
        class TransportItems {
			ITEM_XX(ACE_Canteen_Nearly_Full,1);
        };
    };
	class ACE_Canteen_Nearly_Empty_Item: ACE_Canteen_Item {
        displayName = "Canteen (Nearly-Empty)";
        class TransportItems {
			ITEM_XX(ACE_Canteen_Nearly_Empty,1);
        };
    };
	
	class LandVehicle;
	class Car: LandVehicle {
		class ACE_Actions {
			class ACE_MainActions {
				class btc_ace_Actions {
					displayName = "BTC Menu";
					condition = "";
					exceptions[] = {};
					statement = "";
					priority = 2.1;
					icon = QPATHTOF(data\btc_ace_actions_icon.paa);
					class GVAR(WaterBottle) {
						displayName = "Refill Water Bottle (Half)";
						condition = "'ACE_WaterBottle_Half' in items _player";
						exceptions[] = {};
						icon = QPATHTOF(data\item_waterbottle_refill_icon.paa);
						statement = QUOTE(['ACE_WaterBottle_Half'] call FUNC(Refill));
					};
					class GVAR(WaterBottle_a): GVAR(WaterBottle) {
						displayName = "Refill Water Bottle (Empty)";
						condition = "'ACE_WaterBottle_Empty' in items _player";
						statement = QUOTE(['ACE_WaterBottle_Empty'] call FUNC(Refill));
					};
					
					class GVAR(Canteen) {
						displayName = "Refill Canteen (Nearly-Full)";
						condition = "'ACE_Canteen_Nearly_Full' in items _player";
						exceptions[] = {};
						icon = QPATHTOF(data\item_canteen_refill_icon.paa);
						statement = QUOTE(['ACE_Canteen_Nearly_Full'] call FUNC(Refill));
					};
					class GVAR(Canteen_a): GVAR(Canteen) {
						displayName = "Refill Canteen (Half)";
						condition = "'ACE_Canteen_Half' in items _player";
						statement = QUOTE(['ACE_Canteen_Half'] call FUNC(Refill));
					};
					class GVAR(Canteen_b): GVAR(Canteen) {
						displayName = "Refill Canteen (Nearly-Empty)";
						condition = "'ACE_Canteen_Nearly_Empty' in items _player";
						statement = QUOTE(['ACE_Canteen_Nearly_Empty'] call FUNC(Refill));
					};
					class GVAR(Canteen_c): GVAR(Canteen) {
						displayName = "Refill Canteen (Empty)";
						condition = "'ACE_Canteen_Empty' in items _player";
						statement = QUOTE(['ACE_Canteen_Empty'] call FUNC(Refill));
					};
				};
			};
		};
	};
	class Man;
	class CAManBase: Man {
		class ACE_SelfActions {
			class btc_ace_Actions {
				displayName = "BTC Menu";
				condition = "";
				exceptions[] = {};
				statement = "";
				priority = 2.1;
				icon = QPATHTOF(data\btc_ace_actions_icon.paa);
				class GVAR(WaterBottle) {
					displayName = "Drink Water Bottle (Full)";
					condition = "'ACE_WaterBottle' in items _player";
					exceptions[] = {};
					icon = QPATHTOF(data\item_waterbottle_drink_icon.paa);
					statement = QUOTE(['ACE_WaterBottle'] call FUNC(Drink));
				};
				class GVAR(WaterBottle_a): GVAR(WaterBottle) {
					displayName = "Drink Water Bottle (Half)";
					condition = "'ACE_WaterBottle_Half' in items _player";
					statement = QUOTE(['ACE_WaterBottle_Half'] call FUNC(Drink));
				};
				
				class GVAR(Canteen) {
					displayName = "Drink Canteen (Full)";
					condition = "'ACE_Canteen' in items _player";
					exceptions[] = {};
					icon = QPATHTOF(data\item_canteen_drink_icon.paa);
					statement = QUOTE(['ACE_Canteen'] call FUNC(Drink));
				};
				class GVAR(Canteen_a): GVAR(Canteen) {
					displayName = "Drink Canteen (Nearly-Full)";
					condition = "'ACE_Canteen_Nearly_Full' in items _player";
					statement = QUOTE(['ACE_Canteen_Nearly_Full'] call FUNC(Drink));
				};
				class GVAR(Canteen_b): GVAR(Canteen) {
					displayName = "Drink Canteen (Half)";
					condition = "'ACE_Canteen_Half' in items _player";
					statement = QUOTE(['ACE_Canteen_Half'] call FUNC(Drink));
				};
				class GVAR(Canteen_c): GVAR(Canteen) {
					displayName = "Drink Canteen (Nearly-Empty)";
					condition = "'ACE_Canteen_Nearly_Empty' in items _player";
					statement = QUOTE(['ACE_Canteen_Nearly_Empty'] call FUNC(Drink));
				};
			};
		};
	};
};
class CfgSounds {
	class GVAR(Drink_sound) {
		name = QGVAR(Drink_sound);
		sound[] = {QPATHTOF(data\drink.ogg),2,1,15};
		titles[] = {};
	};
	class GVAR(Refill_sound) {
		name = QGVAR(Refill_sound);
		sound[] = {QPATHTOF(data\pour.ogg),2,1,15};
		titles[] = {};
	};
};

class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
