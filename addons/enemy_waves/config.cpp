#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Enemy Waves";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module_curator), QGVAR(module)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_main", "btc_supply"};
		VERSION_CONFIG;
	};
};

/*
46: Mission display
312: Zeus display
49: Pause menu
602: Inventory
24: Chat box
300: Weapon state
12: Map
160: UAV Terminal
315: 3DEN
*/
class ctrlListBox;
class ctrlListNBox;
class ctrlStatic;
class ctrlButton;
class ctrlStaticTitle;
class ctrlEdit;
class ctrlCombo;
class ctrlCheckboxBaseline;
class ctrlControlsGroupNoScrollbars;
class ctrlStaticBackground;

#include "gui.hpp"
#include "gui_curator.hpp"

class CfgVehicles {
	class Logic;
	class Module_F : Logic
	{
		class AttributesBase
		{
			class Default;
			class ModuleDescription;	// Module description
		};

		// Description base classes (for more information see below):
		class ModuleDescription;
	};

	//Dedicated to Curator interface
	class GVAR(module_curator) : Module_F {
		author = "=BTC= Fyuran";
		scope = 1;
		scopeCurator = 2;
		category = "Effects";
		displayName = "Enemy Waves Module";
		isGlobal = 0; // 0 for server only execution, 1 for global execution, 2 for persistent global execution
		function = QFUNC(curator_init);
		icon = "\z\btc\addons\canteen\data\btc_ace_actions_icon.paa";
		curatorInfoType = QGVAR(RscAttributeEWaves); // Menu displayed when the module is placed or double-clicked on by Zeus
	};
	//To be used only in 3DEN editor
	class GVAR(module) : Module_F {
		author = "=BTC= Fyuran";
		scope = 2;
		scopeCurator = 0;
		isTriggerActivated = 1;				// 1 for module waiting until all synced triggers are activated
		isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
		category = "Effects";
		displayName = "Enemy Waves Module";
		function = QFUNC(spawn);
		icon = "\z\btc\addons\canteen\data\btc_ace_actions_icon.paa";
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Sync a trigger and initiate a =BTC= enemy waves incursion against the closest player who activated the trigger, with passed values";
			sync[] = { "EmptyDetector" };	
		};
		class Attributes : AttributesBase {
			class GVAR(side): Default {
				displayName = "Side"; // Name assigned to UI control class Title
				tooltip = "Change enemies' side"; // Tooltip assigned to UI control class Title
				property = QGVAR(side); // Unique config property name saved in SQM
				control = QGVAR(side); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_enemy_waves_side', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "0";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "NUMBER"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(timeout): Default {
				displayName = "Timeout"; // Name assigned to UI control class Title
				tooltip = "How long module will wait to spawn next wave"; // Tooltip assigned to UI control class Title
				property = QGVAR(timeout); // Unique config property name saved in SQM
				control = QGVAR(timeout); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_enemy_waves_timeout', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "60";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "NUMBER"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(formation): Default {
				displayName = "Formation"; // Name assigned to UI control class Title
				tooltip = "Change enemies' formation"; // Tooltip assigned to UI control class Title
				property = QGVAR(formation); // Unique config property name saved in SQM
				control = QGVAR(formation); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_enemy_waves_formation', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "COLUMN";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "STRING"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(presets): Default {
				displayName = "Presets"; // Name assigned to UI control class Title
				tooltip = "Switch Presets"; // Tooltip assigned to UI control class Title
				property = QGVAR(presets); // Unique config property name saved in SQM
				control = QGVAR(presets); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
			};
			class GVAR(list): Default {
				//displayName = "Enemy Classes"; // Name assigned to UI control class Title
				//tooltip = "Change enemies' classes"; // Tooltip assigned to UI control class Title
				property = QGVAR(list); // Unique config property name saved in SQM
				control = QGVAR(list); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_enemy_waves_list', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = """[]""";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "STRING"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class ModuleDescription : ModuleDescription {};
		};
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
