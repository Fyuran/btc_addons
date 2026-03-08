#include "script_component.hpp"
class CfgPatches { 
	class ADDON {
		name = "=BTC= Toolchain AI Paths";
		units[] = {
            QGVAR(2x2),
            QGVAR(2x4),
            QGVAR(4x4),
            QGVAR(6x6),

            QGVAR(2x2_45),
            QGVAR(2x4_45),
            QGVAR(4x2_45),
            QGVAR(4x4_45),
            QGVAR(4x8_45),

            QGVAR(Wall_4x1),
	        QGVAR(Wall_4x2),
            QGVAR(Wall_6x1),
	        QGVAR(Wall_6x2)
        };
		weapons[] = {};
		requiredAddons[] = {"btc_toolchain_main"};
		url = "https://www.blacktemplars.it/";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		requiredVersion = REQUIRED_VERSION;
        VERSION_CONFIG;
	};
}; 

#include "\z\btc_toolchain\addons\aipaths\models\models.hpp"

class CfgMissions {
	class Missions {
		class GVAR(demo) { // class name MUST match the name in the 'directory' path
            overviewPicture = "a3\missions_f_curator\data\img\showcase_curator_overview_ca.paa";
			briefingName = "=BTC= AIPaths Testing Grounds";
			directory = QPATHTOF(missions\GVAR(demo).VR); // <--- match
            overviewText = "Overview the AIPaths offered by =Black Templars Clan=";
		};
	};
};

class CBA_Extended_EventHandlers_base;
class CfgVehicles {
    //-----Floors-----
    class NonStrategic;
    class GVAR(floor_base): NonStrategic {
        author = "=BTC= Fyuran";
        picture = "pictureStaticObject";
        icon = QPATHTOF(materials\iconAIObject_CA.paa);
        editorCategory = QGVAR(EdCat_AIHelpers);
        vehicleClass = "Helpers";
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        };
    };
    
	class GVAR(2x2): GVAR(floor_base) {
        displayName = "AI Path 2x2"; 
        model = QPATHTOF(models\Floor_2x2.p3d); 
        scope = 2; 
        scopeCurator = 2;
        hiddenSelections[] = { 
            "Plane"
        };
        hiddenSelectionsTextures[] = {
            QPATHTOF(materials\dev_floor_CA.paa)
        };
        editorSubcategory = QGVAR(EdSubcat_Straight);
        editorPreview = QPATHTOF(editorPreviews\2x2.jpg);
	};
    class GVAR(2x4): GVAR(2x2) {
        displayName = "AI Path 2x4"; 
        model = QPATHTOF(models\Floor_2x4.p3d); 
        editorPreview = QPATHTOF(editorPreviews\2x4.jpg);
	};
    class GVAR(4x4): GVAR(2x2) {
        displayName = "AI Path 4x4";
        model = QPATHTOF(models\Floor_4x4.p3d);
        editorPreview = QPATHTOF(editorPreviews\4x4.jpg);
    };
    class GVAR(6x6): GVAR(2x2) {
        displayName = "AI Path 6x6";
        model = QPATHTOF(models\Floor_6x6.p3d); 
        editorPreview = QPATHTOF(editorPreviews\6x6.jpg);
    };

    class GVAR(2x2_45): GVAR(2x2) {
        displayName = "AI Path 2x2(45°)";
        model = QPATHTOF(models\Floor_2x2_45.p3d); 
        editorSubcategory = QGVAR(EdSubcat_Slope);
        editorPreview = QPATHTOF(editorPreviews\2x2_45.jpg);
	};
    class GVAR(2x4_45): GVAR(2x2_45) {
        displayName = "AI Path 2x4(45°)"; 
        model = QPATHTOF(models\Floor_2x4_45.p3d);
        editorPreview = QPATHTOF(editorPreviews\2x4_45.jpg);
	};
    class GVAR(4x2_45): GVAR(2x2_45) {
        displayName = "AI Path 4x2(45°)";
        model = QPATHTOF(models\Floor_4x2_45.p3d);
        editorPreview = QPATHTOF(editorPreviews\4x2_45.jpg);
    };
    class GVAR(4x4_45): GVAR(2x2_45) {
        displayName = "AI Path 4x4(45°)";
        model = QPATHTOF(models\Floor_4x4_45.p3d);
        editorPreview = QPATHTOF(editorPreviews\4x4_45.jpg);
	};
    class GVAR(4x8_45): GVAR(2x2_45) {
        displayName = "AI Path 4x8(45°)";
        model = QPATHTOF(models\Floor_4x8_45.p3d); 
        editorPreview = QPATHTOF(editorPreviews\4x8_45.jpg);
	};


    //-----Walls-----
    class Wall_F;
    class GVAR(wall_base): Wall_F {
        author = "=BTC= Fyuran";
        picture = "pictureStaticObject";
        icon = QPATHTOF(materials\iconAIObject_CA.paa);
        editorCategory = QGVAR(EdCat_AIHelpers);
        vehicleClass = "Helpers";
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        };
    };
    class GVAR(Wall_4x1): GVAR(wall_base) {
        scope = 2; 
		scopeCurator = 2;
		displayName = "AI Wall 4x1";
        model = QPATHTOF(models\Wall_4x1.p3d); 
        editorSubcategory = QGVAR(EdSubcat_Walls);
        editorPreview = QPATHTOF(editorPreviews\Wall_4x1.jpg);
        hiddenSelections[] = { 
            "Wall"
        };
        hiddenSelectionsTextures[] = {
            QPATHTOF(materials\dev_wall_CA.paa)
        }; 
	};
	class GVAR(Wall_4x2): GVAR(Wall_4x1) {
		displayName = "AI Wall 4x2"; 
        model = QPATHTOF(models\Wall_4x2.p3d); 
        editorPreview = QPATHTOF(editorPreviews\Wall_4x2.jpg);
    };
    class GVAR(Wall_6x1): GVAR(Wall_4x1) {
		displayName = "AI Wall 6x1"; 
        model = QPATHTOF(models\Wall_6x1.p3d); 
        editorPreview = QPATHTOF(editorPreviews\Wall_6x1.jpg);
    };
    class GVAR(Wall_6x2): GVAR(Wall_4x1) {
		displayName = "AI Wall 6x2"; 
        model = QPATHTOF(models\Wall_6x2.p3d); 
        editorPreview = QPATHTOF(editorPreviews\Wall_6x2.jpg);
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
    class GVAR(2x2) {
        class GVAR(InitPost) {
            serverInit = QUOTE(_this call FUNC(hideObject));
        };   
    };
    class GVAR(2x4): GVAR(2x2) {};
    class GVAR(4x4): GVAR(2x2) {};
    class GVAR(4x6): GVAR(2x2) {};
    class GVAR(6x6): GVAR(2x2) {};

    class GVAR(2x2_45): GVAR(2x2) {};
    class GVAR(2x4_45): GVAR(2x4) {};
    class GVAR(4x2_45): GVAR(2x2) {};
    class GVAR(4x4_45): GVAR(4x4) {};
    class GVAR(4x8_45): GVAR(2x2) {};

    class GVAR(Wall_4x1): GVAR(2x2) {};
    class GVAR(Wall_4x2): GVAR(2x2) {};
    class GVAR(Wall_6x1): GVAR(2x2) {};
    class GVAR(Wall_6x2): GVAR(2x2) {};
};

class CfgEditorCategories {
    class GVAR(EdCat_AIHelpers) {
        displayName = "AI Helpers";
    };
};

class CfgEditorSubcategories {
    class GVAR(EdSubcat_Straight) {
        displayName = "Straight";
    };

    class GVAR(EdSubcat_Slope) {
        displayName = "45 degrees";
    };

    class GVAR(EdSubcat_Walls) {
        displayName = "Walls";
    };
};
