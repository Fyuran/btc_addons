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

class CfgFunctions {
	class btc_json {
		class functions {
			file = QPATHTOF(functions);
			class callExtension {}; // file path will be <ROOT>\functions\fn_myFunction.sqf";
            class copyFile {};
            class createFile {};
            class deleteFile {};
            class getChunk {};
            class getFile {};
            class renameFile {};
            class retrieveList {};
            class toJSON {};
		};
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

