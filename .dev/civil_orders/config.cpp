#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Civil orders";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_toolchain_main"};
	};
};

//ToDo: Fix this crap
class CfgVehicles {
	class Man;
	class CAManBase: Man {
		class ACE_SelfActions {
			class btc_ace_Actions {
				class GVAR(Deploy) {
					displayName = "Deploy Antenna";
					condition = QUOTE(QQGVAR(DeployableAntenna) in items _player);
					exceptions[] = {};
					icon = QPATHTOF(data\dish.paa);
					statement = QUOTE([_player] call FUNC(deploy));
				};
			};
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

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};
