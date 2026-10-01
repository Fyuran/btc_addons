#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Manual Triggers";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_toolchain_main"};
		VERSION_CONFIG;
	};
};

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

	//To be used only in 3DEN editor
	class GVAR(module) : Module_F {
		author = "=BTC= Fyuran";
		scope = 2;
		scopeCurator = 0;
		isTriggerActivated = 0;				// 1 for module waiting until all synced triggers are activated
		isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
		category = "Effects";
		displayName = "Manual Triggers Module";
		function = QFUNC(init);
		icon = QPATHTOEF(main,data\ace_actions_icon.paa);
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Sync triggers to this module to be able to trigger them manually from ACE menu, buttons' names will be extracted from vehicleVarName";
			sync[] = { "EmptyDetector" };	
		};
		class Attributes : AttributesBase {
			class GVAR(isServer) : Default {
				displayName = "Server Only"; // Name assigned to UI control class Title
				tooltip = "Evaluate trigger code only on server"; // Tooltip assigned to UI control class Title
				property = QGVAR(isServer); // Unique config property name saved in SQM
				control = "Checkbox"; // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// In MP scenario, the expression is called only on server.
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(isServer),_value)]);
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
