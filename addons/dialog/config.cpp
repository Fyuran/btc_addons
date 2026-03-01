#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Dialog";
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

#include "dialog.hpp"

class CfgMissions {
	class Missions {
		class GVAR(demo) { // class name MUST match the name in the 'directory' path
            overviewPicture = "a3\missions_f_curator\data\img\showcase_curator_overview_ca.paa";
			briefingName = "=BTC= Conversation Dialogs Demo";
			directory = QPATHTOF(missions\GVAR(demo).VR); // <--- match
            overviewText = "Overview conversation dialogs offered by =Black Templars Clan=";
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
