#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Stealth";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module)};
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
		category = "Effects";
		displayName = "Stealth Module";
		function = QFUNC(moduleInit);
		icon = QPATHTOEF(main,data\ace_actions_icon.paa);
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Sync group leaders to initiate a =BTC= stealth handle on the groups of the synched objects";
			sync[] = { "AnyAI" };
			optional = 0;	// Synced entity is optional
		};
		class Attributes : AttributesBase {
			class GVAR(debug): Default {
				displayName = "Enable Debug mode";
				tooltip = "Show debug";
				property = QGVAR(debug);
				control = "Checkbox";
				expression = "_this setVariable ['btc_toolchain_stealth_debug', _value];";
				defaultValue = 0;
				typeName = "BOOL";
			};
			class GVAR(threat_distance): Default {
				displayName = "Threat Detection Distance";
				tooltip = "Change how far units will detect a threat";
				property = QGVAR(threat_distance);
				control = "Edit";
				expression = "_this setVariable ['btc_toolchain_stealth_threat_distance', _value];";
				defaultValue = THREAT_DISTANCE;
				typeName = "NUMBER";
			};
			class GVAR(alarm_distance): Default {
				displayName = "Raise Alarm Distance";
				tooltip = "Change how far units will raise an alarm after an active combat situation";
				property = QGVAR(alarm_distance);
				control = "Edit";
				expression = "_this setVariable ['btc_toolchain_stealth_alarm_distance', _value];";
				defaultValue = ALARM_DISTANCE;
				typeName = "NUMBER";
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
