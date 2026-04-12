#include "script_component.hpp"
class CfgPatches {
	class btc_json {
		name = "=BTC= JSON Extension";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {};
		VERSION_CONFIG;
	};
};

class CfgMods {
    class btc_json {
        dir = "@btc_json";
        name = "=BTC= JSON Extension";
        picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca.paa";
        hidePicture = 1;
        hideName = 1;
        actionName = "Website";
        action = "https://www.blacktemplars.it/";
        description = "Issue Tracker = https://github.com/Fyuran/btc/issues";
    };
};

class Extended_PreStart_EventHandlers {
    class btc_json {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class btc_json {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
