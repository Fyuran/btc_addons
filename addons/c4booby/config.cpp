#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= C4 Booby trap";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {
			QGVAR(Land_MetalBarrel_F),
			QGVAR(CargoNet_01_barrels_F),
			QGVAR(CargoNet_01_box_F),
			QGVAR(B_CargoNet_01_ammo_F),
			QGVAR(I_CargoNet_01_ammo_F),
			QGVAR(O_CargoNet_01_ammo_F),
			QGVAR(I_E_CargoNet_01_ammo_F),
			QGVAR(C_IDAP_CargoNet_01_supplies_F)
		};
		url = "http://www.blacktemplars.altervista.org";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_main", "ace_main"};
		VERSION_CONFIG;
	};
};

class CfgMissions {
	class Missions {
		class GVAR(testingGrounds) { // class name MUST match the name in the 'directory' path
            overviewPicture = "a3\missions_f_curator\data\img\showcase_curator_overview_ca.paa";
			briefingName = "=BTC= C4Booby Testing Grounds";
			directory = "z\btc\addons\c4booby\missions\btc_c4booby_testingGrounds.VR"; // <--- match
            overviewText = "Overview the C4 Booby Traps by =Black Templars Clan=";
		};
	};
};

class CfgVehicles {
	class Land_MetalBarrel_F;
	class GVAR(Land_MetalBarrel_F): Land_MetalBarrel_F {
		author = "=BTC= Fyuran";
		displayName = "Metal Barrel (C4)";
		class Attributes {
			class GVAR(Land_MetalBarrel_F_EndTime) {
				displayName = "Edit timer"; // Name assigned to UI control class Title
				tooltip = "Change timeout before detonation"; // Tooltip assigned to UI control class Title
				property = QGVAR(Land_MetalBarrel_F_EndTime); // Unique config property name saved in SQM
				control = "Edit"; // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// c4booby_endtime is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['c4booby_endtime',_value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = "60";
				//--- Optional properties
				unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "NUMBER"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
		};
	};
	class CargoNet_01_barrels_F;
	class GVAR(CargoNet_01_barrels_F): CargoNet_01_barrels_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net (C4-Barrels)";
		class Attributes {
			class GVAR(CargoNet_01_barrels_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(CargoNet_01_barrels_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class CargoNet_01_box_F;
	class GVAR(CargoNet_01_box_F): CargoNet_01_box_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net (C4-Box)";
		class Attributes {
			class GVAR(CargoNet_01_box_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(CargoNet_01_box_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class B_CargoNet_01_ammo_F;
	class GVAR(B_CargoNet_01_ammo_F): B_CargoNet_01_ammo_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net [C4-NATO]";
		class Attributes {
			class GVAR(B_CargoNet_01_ammo_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(B_CargoNet_01_ammo_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class I_CargoNet_01_ammo_F;
	class GVAR(I_CargoNet_01_ammo_F): I_CargoNet_01_ammo_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net [C4-AAF]";
		class Attributes {
			class GVAR(I_CargoNet_01_ammo_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(I_CargoNet_01_ammo_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class O_CargoNet_01_ammo_F;
	class GVAR(O_CargoNet_01_ammo_F): O_CargoNet_01_ammo_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net [C4-CSAT]";
		class Attributes {
			class GVAR(O_CargoNet_01_ammo_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(O_CargoNet_01_ammo_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class I_E_CargoNet_01_ammo_F;
	class GVAR(I_E_CargoNet_01_ammo_F): I_E_CargoNet_01_ammo_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net [C4-LDF]";
		class Attributes {
			class GVAR(I_E_CargoNet_01_ammo_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(I_E_CargoNet_01_ammo_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
	class C_IDAP_CargoNet_01_supplies_F;
	class GVAR(C_IDAP_CargoNet_01_supplies_F): C_IDAP_CargoNet_01_supplies_F {
		author = "=BTC= Fyuran";
		displayName = "Cargo Net [C4-IDAP]";
		class Attributes {
			class GVAR(C_IDAP_CargoNet_01_supplies_F_EndTime) {
				displayName = "Edit timer"; 
				tooltip = "Change timeout before detonation";
				property = QGVAR(C_IDAP_CargoNet_01_supplies_F_EndTime);
				control = "Edit";
				expression = "_this setVariable ['c4booby_endtime',_value];";
				defaultValue = "60";
				unique = 0;
				validate = "number";
				typeName = "NUMBER";
			};
		};
	};
};
class CfgSounds {
	class GVAR(defused) {
		name = QGVAR(defused);
		sound[] = {QPATHTOF(sounds\defused.ogg),2,1,15};
		titles[] = {};
	};
	class GVAR(timerClick) {
		name = QGVAR(timerClick);
		sound[] = {QPATHTOF(sounds\timerClick.ogg),2,1,15};
		titles[] = {};
	};
	class GVAR(timerClickShort) {
		name = QGVAR(timerClickShort);
		sound[] = {QPATHTOF(sounds\timerClickShort.ogg),2,1,15};
		titles[] = {};
	};
	class GVAR(timerEnd) {
		name = QGVAR(timerEnd);
		sound[] = {QPATHTOF(sounds\timerEnd.ogg),2,1,15};
		titles[] = {};
	};
};

class Extended_InitPost_EventHandlers {
	class GVAR(Land_MetalBarrel_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(CargoNet_01_barrels_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(CargoNet_01_box_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(B_CargoNet_01_ammo_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(I_CargoNet_01_ammo_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(O_CargoNet_01_ammo_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(I_E_CargoNet_01_ammo_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
	class GVAR(C_IDAP_CargoNet_01_supplies_F) {
		class GVAR(objectInit) {
			serverInit = QUOTE(_this call FUNC(objectInit));
		};
	};
};

class Extended_Deleted_EventHandlers {
	class GVAR(Land_MetalBarrel_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(CargoNet_01_barrels_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(CargoNet_01_box_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(B_CargoNet_01_ammo_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(I_CargoNet_01_ammo_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(O_CargoNet_01_ammo_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(I_E_CargoNet_01_ammo_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
		};
	};
	class GVAR(C_IDAP_CargoNet_01_supplies_F) {
		class GVAR(deleted) {
			deleted = QUOTE(_this call FUNC(deleteObject));
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
