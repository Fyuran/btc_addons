#include "script_component.hpp"

class CfgPatches
{
	class ADDON
	{
		name = "=BTC= Toolchain Insignia";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {};
		url = "https://www.blacktemplars.it/";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {
			"A3_Data_F",
			"A3_Characters_F",
			"A3_Ui_F",
			"ace_interact_menu",
			"btc_toolchain_main"
		};
		VERSION_CONFIG;
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

class btc_ace_Actions;
class CfgVehicles
{
	class Man;
	class CAManBase: Man
	{
		class ACE_SelfActions
		{
			class btc_ace_Actions: btc_ace_Actions
			{
				class GVAR(createDialog)
				{
					displayName = "Change Insignia";
					condition = "true";
					exceptions[] = {};
					icon = QPATHTOEF(main,data\iconBtcA.paa);
					statement = QUOTE([] call FUNC(createDialog); [] call FUNC(createCamera));
				};
			};
		};
	};
};


class ctrlListbox;
class ctrlStaticPicture;
class ctrlControlsGroupNoScrollbars;

#include "gui.hpp"
#include "CfgUnitInsignia.hpp"
