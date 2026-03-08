#include "script_component.hpp"
#define true 1
#define false 0

class CfgPatches {
    class ADDON {
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

class CfgMods {
    class PREFIX {
        dir = "@btc_toolchain";
        name = "=BTC= Toolchain";
        picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca.paa";
        hidePicture = true;
        hideName = true;
        actionName = "Website";
        action = "https://www.blacktemplars.it/";
        description = "Issue Tracker = https://github.com/Fyuran/btc/issues";
    };
};
