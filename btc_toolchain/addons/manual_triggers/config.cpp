#include "script_component.hpp"
class CfgPatches
{
	class ADDON
	{
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

class CfgVehicles
{
	class Man;
	class CAManBase: Man
	{
		class ACE_SelfActions
		{
			class btc_ace_Actions
			{
				displayName = "BTC Menu";
				condition = "";
				exceptions[] = {};
				statement = "";
				priority = 2.1;
				icon = QPATHTOEF(main,data\iconBtcA.paa);
				class GVAR(menu)
				{
					displayName = "Manual Triggers";
					condition = QUOTE([] call FUNC(canShow));
					exceptions[] = {};
					statement = "";
					priority = 3;
					icon = QPATHTOF(data\manual_trigger_icon.paa);
				};
			};
		};
	};

	class Logic;
	class Module_F : Logic
	{
		class AttributesBase
		{
			class ModuleDescription;	// Module description
		};

		// Description base classes (for more information see below):
		class ModuleDescription;
	};

	//To be used only in 3DEN editor
	class GVAR(module) : Module_F
	{
		author = MAIN_AUTHOR;
		scope = 2;
		scopeCurator = 0;
		isTriggerActivated = 0;				// 1 for module waiting until all synced triggers are activated
		isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
		category = "BTC_Modules";
		displayName = "Manual Triggers";
		function = QFUNC(init);
		icon = QPATHTOEF(main,data\iconBtcA.paa);
		isGlobal = 0;
		class ModuleDescription: ModuleDescription
		{
			description = "Sync triggers to this module to be able to trigger them manually from ACE menu, buttons' names will be extracted from vehicleVarName";
			sync[] = { "EmptyDetector" };	
		};
		class Attributes : AttributesBase
		{
			class ModuleDescription : ModuleDescription {};
		};
	};
};

class Extended_PreStart_EventHandlers
{
    class ADDON
    {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers
{
    class ADDON
    {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
