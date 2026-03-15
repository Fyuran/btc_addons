class GVAR(gui) {
	idd = BRIDGE_DISPLAY;
	class ControlsBackground {
		class Frame: RscFrame {
			x = "0.04625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.15 * safezoneW";
			h = "0.231 * safezoneH";
		};
		class Background: RscText {
			x = "0.04625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.15 * safezoneW";
			h = "0.231 * safezoneH";
			colorBackground[] = {0, 0, 0, 0.5};
		};
		class BackgroundPicture: RscText {
			x = "0.19625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.0257812 * safezoneW";
			h = "0.044 * safezoneH";
			colorBackground[] = {0, 0, 0, 0.5};
		};
		class FramePicture: RscFrame {
			x = "0.19625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.0257812 * safezoneW";
			h = "0.044 * safezoneH";
		};
	};
	class Controls {
		class RscCtrlGrp_1: RscControlsGroupNoScrollbars {
			idc = CTRL_GRP;
			x = "0.04625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.15 * safezoneW";
			h = "0.231 * safezoneH";
			class Controls {
				class RscStructuredText_1000: RscStructuredText {
					idc = 1000;
					text = "<t color='#E06B1F' font='PuristaBold'>[Numpad +]</t> Add bridge segment"; //--- ToDo: Localize;
					x = "0";
					y = "0";
					w = "0.15 * safezoneW";
					h = "0.033 * safezoneH";
				};
				class RscStructuredText_1001: RscStructuredText_1000 {
					idc = 1001;
					text = "<t color='#E06B1F' font='PuristaBold'>[Numpad -]</t> Remove bridge segment"; //--- ToDo: Localize;
					y = "0.033 * safezoneH";
				};
				class RscStructuredText_1002: RscStructuredText_1000 {
					idc = 1002;
					text = "<t color='#E06B1F' font='PuristaBold'>[Numpad Enter]</t> Finish Bridge"; //--- ToDo: Localize;
					y = "0.066 * safezoneH";
				};
				class RscStructuredText_1003: RscStructuredText_1000 {
					idc = 1003;
					text = "<t color='#E06B1F' font='PuristaBold'>[Q]</t> Increase Bridge Height"; //--- ToDo: Localize;
					y = "0.099 * safezoneH";
				};
				class RscStructuredText_1004: RscStructuredText_1000 {
					idc = 1004;
					text = "<t color='#E06B1F' font='PuristaBold'>[Z]</t> Decrease Bridge Height"; //--- ToDo: Localize;
					y = "0.132 * safezoneH";
				};
				class RscStructuredText_1005: RscStructuredText_1000 {
					idc = 1005;
					text = "<t color='#E06B1F' font='PuristaBold'>[Escape]</t> Close off Bridge GUI"; //--- ToDo: Localize;
					y = "0.165 * safezoneH";
				};
				class RscStructuredText_1006: RscStructuredText_1000 {
					idc = 1006;
					text = "<t color='#b40379' font='PuristaBold'>Bridge Height: 0</t>"; //--- ToDo: Localize;
					y = "0.198 * safezoneH";
				};
			};
		};
		class RscPicture_1201: RscPicture {
			idc = 1201;
			text = QPATHTOF(data\pto.paa);
			colorText[] = {0, 1, 0, 1};
			x = "0.19625 * safezoneW + safezoneX";
			y = "0.5 * safezoneH + safezoneY";
			w = "0.0257812 * safezoneW";
			h = "0.044 * safezoneH";
		};
	};
};

