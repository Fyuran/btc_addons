#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Supply Drop";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module_curator), QGVAR(module)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_main"};
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
#include "gui_presets.hpp"

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
		displayName = "Supply Module";
		isGlobal = 0; // 0 for server only execution, 1 for global execution, 2 for persistent global execution
		function = QFUNC(curator_init);
		icon = "\z\btc\addons\canteen\data\btc_ace_actions_icon.paa";
		curatorInfoType = QGVAR(RscAttributeSupply); // Menu displayed when the module is placed or double-clicked on by Zeus
	};
	//To be used only in 3DEN editor
	class GVAR(module) : Module_F {
		author = "=BTC= Fyuran";
		scope = 2;
		scopeCurator = 0;
		isTriggerActivated = 1;				// 1 for module waiting until all synced triggers are activated
		isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
		category = "Effects";
		displayName = "Supply Module";
		function = QFUNC(drop);
		icon = "\z\btc\addons\canteen\data\btc_ace_actions_icon.paa";
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Sync a trigger and initiate a =BTC= supply drop with passed values";
			sync[] = { "EmptyDetector" };	
		};
		class Attributes : AttributesBase {
			class GVAR(class): Default {
				displayName = "Vehicle class"; // Name assigned to UI control class Title
				tooltip = "Change vehicle carrying supplies"; // Tooltip assigned to UI control class Title
				property = QGVAR(vehicleClass); // Unique config property name saved in SQM
				control = QGVAR(class); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// btc_supply_class is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_supply_vehicleClass', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "''";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "STRING"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(enableDamage): Default {
				displayName = "Allow Vehicle damage"; // Name assigned to UI control class Title
				tooltip = "Change if vehicle can be damaged"; // Tooltip assigned to UI control class Title
				property = QGVAR(enableDamage); // Unique config property name saved in SQM
				control = QGVAR(enableDamage); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// btc_supply_enableDamage is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_supply_enableDamage', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "true";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "BOOL"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(presets): Default {
				displayName = "Presets"; // Name assigned to UI control class Title
				tooltip = "Switch Presets"; // Tooltip assigned to UI control class Title
				property = QGVAR(presets); // Unique config property name saved in SQM
				control = QGVAR(presets); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// btc_supply_list_value is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "''";
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "STRING"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(list): Default {
				//displayName = "Vehicle inventory"; // Name assigned to UI control class Title
				//tooltip = "Change supplies"; // Tooltip assigned to UI control class Title
				property = QGVAR(list_value); // Unique config property name saved in SQM
				control = QGVAR(list); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// btc_supply_list_value is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_supply_list_value', _value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "''";
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
