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

#include "CfgSounds.hpp"

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
		function = QFUNC(init);
		icon = QPATHTOEF(main,data\ace_actions_icon.paa);
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Sync group leaders to initiate a =BTC= stealth FSM on the groups of the synched objects";
			sync[] = { "AnyAI" };
			optional = 0;	// Synced entity is optional
		};
		class Attributes : AttributesBase {
			class GVAR(debug): Default {
				displayName = "Enable Debug mode";
				tooltip = "Show debug(Only in Singleplayer)";
				property = QGVAR(debug);
				control = "Checkbox";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(debug),_value)]);
				defaultValue = 0;
				typeName = "BOOL";
			};
			class GVAR(radio_delay): Default {
				displayName = "Radio calls delay";
				tooltip = "Delay in seconds between radio calls, avoid setting very low numbers";
				property = QGVAR(radio_delay);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(radio_delay),_value)]);
				defaultValue = 10;
				typeName = "NUMBER";
			};
/* 			class GVAR(investigate_offset): Default {
				displayName = "Investigation offset";
				tooltip = "Change how much extra time does patrol to investigate take to be triggered";
				property = QGVAR(investigate_offset);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(investigate_offset),_value)]);
				defaultValue = 0;
				typeName = "NUMBER";
			};
			class GVAR(cover_offset): Default {
				displayName = "Cover offset";
				tooltip = "Change how much extra time does investigate to cover phase take to be triggered";
				property = QGVAR(cover_offset);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(cover_offset),_value)]);
				defaultValue = 0;
				typeName = "NUMBER";
			};
			class GVAR(alarm_offset): Default {
				displayName = "Alarm offset";
				tooltip = "Change how much extra time does cover to alarm phase take to be triggered";
				property = QGVAR(alarm_offset);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(alarm_offset),_value)]);
				defaultValue = 0;
				typeName = "NUMBER";
			};*/
			class GVAR(limit_offset): Default {
				displayName = "Alarm duration offset";
				tooltip = "Change how much extra time alarm phase is going to last";
				property = QGVAR(limit_offset);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(limit_offset),_value)]);
				defaultValue = 0;
				typeName = "NUMBER";
			};
			class GVAR(threat_distance): Default {
				displayName = "Threat Detection Distance";
				tooltip = "Change how far units will detect a threat";
				property = QGVAR(threat_distance);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(threat_distance),_value)]);
				defaultValue = THREAT_DISTANCE;
				typeName = "NUMBER";
			};
			class GVAR(alarm_distance): Default {
				displayName = "Raise Alarm Distance";
				tooltip = "Change how far units will raise an alarm after an active combat situation";
				property = QGVAR(alarm_distance);
				control = "Edit";
				expression = QUOTE(_this setVariable [ARR_2(QQGVAR(alarm_distance),_value)]);
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
