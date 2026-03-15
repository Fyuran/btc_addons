#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Bridge";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(Bridge_Layer)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"A3_Soft_F_Enoch_Truck_01", "btc_toolchain_tools", "rhs_c_pontoon"};
		VERSION_CONFIG;
	};
};

class CfgMods {
    class PREFIX {
        dir = "@btc_bridge";
        name = "=BTC= Bridge";
        picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca.paa";
        hidePicture = 1;
        hideName = 1;
        actionName = "Website";
        action = "https://www.blacktemplars.it/";
        description = "Issue Tracker = https://github.com/Fyuran/btc/issues";
    };
};

class RscFrame;
class RscPicture;
class RscText;
class RscStructuredText;
class RscControlsGroup;
class RscControlsGroupNoScrollbars: RscControlsGroup {};
#include "gui.hpp"

class CfgVehicles {
	class B_Truck_01_flatbed_F;
	class GVAR(Bridge_Layer): B_Truck_01_flatbed_F {
		displayName = "HEMTT Flatbed (Bridge)";
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

class Extended_InitPost_EventHandlers {
	class GVAR(Bridge_Layer) {
		class GVAR(initPost) {
			init = "[_this select 0] call btc_bridge_fnc_initPost;";
		};
	};
};
