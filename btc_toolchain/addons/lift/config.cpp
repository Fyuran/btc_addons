#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Heli Lift";
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
			briefingName = "=BTC= Heli Lift";
			directory = QPATHTOF(missions\GVAR(demo).VR); // <--- match
            overviewText = "Overview Lift assistance tools offered by =Black Templars Clan=";
		};
	};
};

class CfgVehicles {
    class Helicopter {
        class ACE_SelfActions {
            class GVAR(deploy_ropes) {
                displayName = "$STR_ACE_Fastroping_Interaction_deployRopes";
                condition = "!(missionNamespace getVariable[""btc_toolchain_lift_ropes_deployed"", false]) && {(driver vehicle player) isEqualTo player} && {(getPosATL player) select 2 > 4}";
                exceptions[] = {};
                statement = "[] spawn btc_toolchain_lift_fnc_deployRopes;";
                icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\container_ca.paa";
            };
            class GVAR(destroy_ropes) {
                displayName = "$STR_ACE_Fastroping_Interaction_cutRopes";
                condition = "(missionNamespace getVariable[""btc_toolchain_lift_ropes_deployed"", false]) && {(driver vehicle player) isEqualTo player}";
                exceptions[] = {};
                statement = "[] spawn btc_toolchain_lift_fnc_destroyRopes;";
                icon = "\z\ace\addons\logistics_wirecutter\ui\wirecutter_ca.paa";
            };
        };
    };
};

class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        clientInit = QUOTE(call COMPILE_SCRIPT(XEH_clientInit));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
