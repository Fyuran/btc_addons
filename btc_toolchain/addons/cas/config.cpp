#include "script_component.hpp"
class CfgPatches
{
	class ADDON
	{
		name = "=BTC= Toolchain CAS";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module), QGVAR(module_curator)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {
			"A3_Modules_F",
			"3DEN",
			"btc_toolchain_main", 
			"btc_toolchain_gui"
		};
		VERSION_CONFIG;
	};
};

class ctrlStatic;
class ctrlEdit;
class ctrlCombo;
class ctrlCheckboxBaseline;
class ctrlToolbox;
class ctrlControlsGroupNoScrollbars;
class ctrlListbox;
class ctrlButton;
class ctrlStaticTitle;

class CfgVehicles
{
	class Logic;
	class Module_F: Logic
	{
		class AttributesBase
		{
			class Default;
			class ModuleDescription;
		};

		class ModuleDescription;
	};

	#include "module.hpp"
};

#include "cfg3den.hpp"

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
