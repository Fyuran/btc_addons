#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Factions";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		#include "weapons.hpp"
		#include "units.hpp"
		#include "dependencies.hpp"
		VERSION_CONFIG;
	};
};

class CfgMods {
    class PREFIX {
        dir = "@btc_factions";
        name = "=BTC= Factions";
        picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca.paa";
        hidePicture = 1;
        hideName = 1;
        actionName = "Website";
        action = "https://www.blacktemplars.it/";
        description = "Issue Tracker = https://github.com/Fyuran/btc/issues";
    };
};

class CfgFactionClasses {
	class rhs_faction_rva;
	class GVAR(russian_winter_force):  rhs_faction_rva {
		displayName = "=BTC= Russian Winter Force";
    	author = "Fyuran";
	};
	class GVAR(russian_invasion_force):  rhs_faction_rva {
		displayName = "=BTC= Russian Invasion Force";
    	author = "Fyuran";
	};
	class GVAR(shadow_company):  rhs_faction_rva {
		displayName = "=BTC= Shadow Company";
    	author = "Fyuran";
	};
};

class CfgWeapons {
	#include "forward_declarations_weapons.hpp"
	#include "russian_winter_force_weapons.hpp"
	#include "shadow_company_weapons.hpp"
};

class CfgVehicles {
	//Edit the retarded side lock on Black MLO_Ghost uniforms
	class VSM_OGA_Crye_grey_Uniform;
	class MLO_OGA_Crye_black_Uniform: VSM_OGA_Crye_grey_Uniform {
		modelSides[] = {0, 1, 2, 3};
	};
	#include "forward_declarations.hpp"
	#include "russian_winter_force.hpp"
	#include "russian_invasion_force.hpp"
	#include "shadow_company.hpp"
};

class CfgGroups {
	class East
	{
		#include "russian_winter_force_groups.hpp"
		#include "russian_invasion_force_groups.hpp"
		#include "shadow_company_groups.hpp"
	};
};
