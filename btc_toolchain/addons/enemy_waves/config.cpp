#include "script_component.hpp"
class CfgPatches
{
	class ADDON
	{
		name = "=BTC= Toolchain Enemy Waves";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module_curator), QGVAR(module)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_toolchain_main", "btc_toolchain_supply", "btc_toolchain_gui"};
		VERSION_CONFIG;
	};
};

/*
46: Mission display
312: RscDisplayCurator
49: Pause menu
602: Inventory
24: Chat box
300: Weapon state
12: Map
160: UAV Terminal
313: Display3DEN
315: Display3DENEditAttributes
*/
class ctrlListbox;
class ctrlListNBox;
class ctrlStatic;
class ctrlButton;
class ctrlStaticTitle;
class ctrlEdit;
class ctrlCombo;
class ctrlCheckboxBaseline;
class ctrlControlsGroupNoScrollbars;
class ctrlStaticBackground;
class ctrlButtonSearch;
class ctrlTree;
class ctrlToolbox;

//#include "gui.hpp"

class CfgVehicles
{
	class Logic;
	class Module_F : Logic
	{
		class AttributesBase
		{
			class Default;
			class Combo : Default {};
			class ModuleDescription;	// Module description
		};

		// Description base classes (for more information see below):
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
