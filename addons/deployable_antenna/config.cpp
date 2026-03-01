#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Deployable Antennas";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(DeployableAntenna_Item)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {QGVAR(DeployableAntenna)};
		requiredAddons[] = {"btc_toolchain_main"};
		VERSION_CONFIG;
	};
};

class CfgWeapons {
    class CBA_MiscItem_ItemInfo;
	class CBA_MiscItem;

	class GVAR(DeployableAntenna) : CBA_MiscItem {
		scope = 2;
		scopeArsenal = 2;
		displayName = "Folded Deployable Antenna";
		model = "\a3\weapons_f\Ammoboxes\bags\Backpack_Tortila.p3d";
		picture = QPATHTOF(data\dish_pic.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 55;
        };
	};
};

#define COMMA ,
class CfgVehicles {
	class Items_Base_F; //ThingX
	class Item_Base_F; //WeaponHolder
	class Land_SatelliteAntenna_01_F: Items_Base_F {
		class ACE_Actions {
			class ACE_MainActions {
				condition = "true";
				displayName = ACECSTRING(interaction,MainAction);
                position[] = {{0,0,0}};
                selection = "";
                distance = 4;
				class btc_ace_Actions {
					displayName = "BTC Menu";
					condition = "true";
					exceptions[] = {};
					statement = "";
					priority = 2.1;
					icon = QPATHTOEF(canteen,data\btc_ace_actions_icon.paa);
					class GVAR(Dismantle) {
						displayName = "Dismantle Antenna";
						condition = QUOTE(_player canAdd QQGVAR(DeployableAntenna));
						exceptions[] = {};
						icon = QPATHTOF(data\dish.paa);
						statement = QUOTE([_player COMMA _target] call FUNC(dismantle));
					};
				};
			};
		};
	};

	class GVAR(DeployableAntenna_Item): Item_Base_F {
        author = "=BTC= Fyuran";
		icon = "iconObject_5x4";
        displayName = "Folded Deployable Antenna"; 
        model = "\a3\Weapons_F\DummyItem.p3d"; 
        scope = 2; 
        picture = "pictureStaticObject"; 
		editorPreview = "\a3\EditorPreviews_F_Exp\Data\CfgVehicles\Land_SatelliteAntenna_01_F.jpg";
		editorCategory = "EdCat_Equipment";
		editorSubcategory = "EdSubcat_InventoryItems";
		vehicleClass = "Items";	
		scopeCurator = 2;
		class TransportItems {
			ITEM_XX(GVAR(DeployableAntenna),1);
		};
	};
	
	class Man;
	class CAManBase: Man {
		class ACE_SelfActions {
			class btc_ace_Actions {
				class GVAR(Deploy) {
					displayName = "Deploy Antenna";
					condition = QUOTE(QQGVAR(DeployableAntenna) in items _player);
					exceptions[] = {};
					icon = QPATHTOF(data\dish.paa);
					statement = QUOTE([_player] call FUNC(deploy));
				};
			};
		};
	};
};

class CfgSounds {
	class GVAR(Jammer_Sound) {
		name = QGVAR(Jammer_Sound);
		sound[] = {QPATHTOF(data\jammer.ogg), 1, 1, 50};
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
