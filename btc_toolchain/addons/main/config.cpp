#include "script_component.hpp"

class CfgPatches
{
    class ADDON
    {
        name = "=BTC= Toolchain Main";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main", "ace_main"};
        author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
        url = "https://www.blacktemplars.it/";
        VERSION_CONFIG;
    };
};

class CfgFactionClasses
{
    class NO_CATEGORY;
    class BTC_Modules: NO_CATEGORY
    {
        displayName = "=BTC= Modules";
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
			};
		};
	};
};

class CfgMods
{
    class PREFIX
    {
        dir = "@btc_toolchain";
        name = "=BTC= Toolchain";
        picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca.paa";
        hidePicture = 1;
        hideName = 1;
        actionName = "Website";
        action = "https://www.blacktemplars.it/";
        description = "Issue Tracker = https://github.com/Fyuran/btc/issues";
    };
};
