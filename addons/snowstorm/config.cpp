#include "script_component.hpp"
class CfgPatches {
	class ADDON {
		name = "=BTC= Snowstorm";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {QGVAR(module)};
		url = "http://www.blacktemplars.it";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_main", "ace_medical"};
		VERSION_CONFIG;
	};
};

class CfgMissions {
	class Missions {
		class btc_snowstorm_demo { // class name MUST match the name in the 'directory' path
            overviewPicture = "a3\missions_f_curator\data\img\showcase_curator_overview_ca.paa";
			briefingName = "=BTC= Snowstorm Demo";
			directory = "z\btc\addons\snowstorm\missions\btc_snowstorm_demo.Stratis"; // <--- match
            overviewText = "Overview Snowstorm offered by =Black Templars Clan=";
		};
	};
};

class Cfg3DEN {
	class Attributes {
		class Title;
		class Slider: Title {
			class Controls {
				class Title;
				class Value;
				class Edit;
			};
		};
		class GVAR(Slider_0_to_1) : Slider {
			attributeLoad = "[_this, _value] call btc_snowstorm_fnc_initSlider";
			attributeSave = "sliderPosition (_this controlsGroupCtrl 52)";
			onLoad = "[_this, _value] call btc_snowstorm_fnc_initSlider";
			class Controls: Controls {
				class Edit: Edit {
					idc = 50;
				};
				class Title: Title {
					idc = 51;
				};
				class Value: Value {
					idc = 52;
					sliderRange[] = {0,1};
					sliderStep = 0.1;
					lineSize = 0.1;
				};
			};
		};
		class GVAR(Slider_5000to5000) : Slider {
			attributeLoad = "[_this, _value] call btc_snowstorm_fnc_initSlider";
			attributeSave = "sliderPosition (_this controlsGroupCtrl 52)";
			onLoad = "[_this, _value] call btc_snowstorm_fnc_initSlider";
			class Controls: Controls {
				class Edit: Edit {
					idc = 50;
				};
				class Title: Title {
					idc = 51;
				};
				class Value: Value {
					idc = 52;
					sliderRange[] = {-5000,5000};
					sliderStep = 100;
					lineSize = 100;
				};
			};
		};
	};
};

class CfgVehicles {
	class Logic;
	class Module_F : Logic
	{
		class AttributesBase
		{
			class Default;
			class ModuleDescription;	// Module description
		};

		// Description base classes (for more information see below):
		class ModuleDescription;
	};

	class GVAR(module) : Module_F {
		author = "=BTC= Fyuran";
		scope = 2;
		scopeCurator = 1;
		category = "Effects";
		displayName = "Snowstorm Module";
		function = QFUNC(moduleInit);
		icon = "\z\btc\addons\canteen\data\btc_ace_actions_icon.paa";
		isGlobal = 0;
		class ModuleDescription: ModuleDescription {
			description = "Initiates a =BTC= snowstorm with passed values";
		};
		class Attributes : AttributesBase {
			class GVAR(fogValue): Default {
				displayName = "Fog Value"; // Name assigned to UI control class Title
				tooltip = "Change fog value"; // Tooltip assigned to UI control class Title
				property = QGVAR(fogValue); // Unique config property name saved in SQM
				control = QGVAR(Slider_0_to_1); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
				// Expression called when applying the attribute in Eden and at the scenario start
				// The expression is called twice - first for data validation, and second for actual saving
				// Entity is passed as _this, value is passed as _value
				// btc_snowstorm_fogValue is replaced by attribute config name. It can be used only once in the expression
				// In MP scenario, the expression is called only on server.
				expression = "_this setVariable ['btc_snowstorm_fogValue',_value];";
				// Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
				// Must be of type string
				// Entity (unit, group, marker, comment etc.) is passed as _this
				// Returned value is the default value
				// Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
				// Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
				defaultValue = 0.5;
				//--- Optional properties
				//unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
				//validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
				typeName = "NUMBER"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
			};
			class GVAR(fogDecay): GVAR(fogValue) {
				displayName = "Fog Decay";
				tooltip = "Change fog decay value";
				property = QGVAR(fogDecay);
				defaultValue = 0;
				expression = "_this setVariable ['btc_snowstorm_fogDecay',_value];";
			};
			class GVAR(fogBase): GVAR(fogValue) {
				displayName = "Fog Base";
				tooltip = "Change fog base altitude in ASL meters";
				control = QGVAR(Slider_5000to5000);
				property = QGVAR(fogBase);
				defaultValue = 0;
				expression = "_this setVariable ['btc_snowstorm_fogBase',_value];";
			};
			class GVAR(duration) {
				displayName = "Snowstorm Duration";
				tooltip = "Change snowstorm duration (-1 for infinite)";
				property = QGVAR(duration);
				control = "Edit";
				expression = "_this setVariable ['btc_snowstorm_duration',_value];";
				defaultValue = -1;
				typeName = "NUMBER";
			};
			class GVAR(intensity_min) {
				displayName = "Wind intensity minimum";
				tooltip = "Change snowstorm wind intensity minimum";
				property = QGVAR(intensity_min);
				control = "Edit";
				expression = "_this setVariable ['btc_snowstorm_wind_min',_value];";
				defaultValue = 20;
				typeName = "NUMBER";
			};
			class GVAR(intensity_avg) {
				displayName = "Wind intensity average";
				tooltip = "Change snowstorm wind intensity average";
				property = QGVAR(intensity_avg);
				control = "Edit";
				expression = "_this setVariable ['btc_snowstorm_wind_avg',_value];";
				defaultValue = 30;
				typeName = "NUMBER";
			};
			class GVAR(intensity_max) {
				displayName = "Wind intensity maximum";
				tooltip = "Change snowstorm wind intensity maximum";
				property = QGVAR(intensity_max);
				control = "Edit";
				expression = "_this setVariable ['btc_snowstorm_wind_max',_value];";
				defaultValue = 40;
				typeName = "NUMBER";
			};
			class ModuleDescription : ModuleDescription {};
		};
	};
};

class CfgSounds {
	class GVAR(wind_transition) {
		name = QGVAR(wind_transition);
		sound[] = {QPATHTOF(sounds\wind_transition.ogg), 5,1};
		titles[] = {};
	};
	class GVAR(indoor_h_windLoop) {
		name = QGVAR(indoor_h_windLoop);
		sound[] = {QPATHTOF(sounds\indoor_h_windLoop.ogg), 1,1};
		titles[] = {};
	};
	class GVAR(h_windLoop) {
		name = QGVAR(h_windLoop);
		sound[] = {QPATHTOF(sounds\h_windLoop.ogg), 1,1};
		titles[] = {};
	};
	class GVAR(indoor_h_windLoop_2) {
		name = QGVAR(indoor_h_windLoop_2);
		sound[] = {QPATHTOF(sounds\indoor_h_windLoop_2.ogg), 1,1};
		titles[] = {};
	};
	class GVAR(h_windLoop_2) {
		name = QGVAR(h_windLoop_2);
		sound[] = {QPATHTOF(sounds\h_windLoop_2.ogg), 1,1};
		titles[] = {};
	};
	class GVAR(wolf1) {
		name = QGVAR(wolf1);
		sound[] = {QPATHTOF(sounds\Wolf1.ogg), 1,1};
		titles[] = {};
	};
	class GVAR(wolf2) {
		name = QGVAR(wolf2);
		sound[] = {QPATHTOF(sounds\Wolf2.ogg), 1,1};
		titles[] = {};
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

class Extended_Deleted_EventHandlers {
	class GVAR(module) {
		class GVAR(module_deleted) {
			serverDeleted = QUOTE([] call FUNC(terminate););
		};
	};
};
