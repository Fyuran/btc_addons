#define CENTER (0.5 * safeZoneW + safeZoneX)
#define GUI_GRID_WAbs ((safezoneW / safezoneH) min 1.2)
#define GUI_GRID_HAbs (GUI_GRID_WAbs / 1.2)
#define GUI_GRID_X safezoneX
#define GUI_GRID_Y (safezoneY + safezoneH - GUI_GRID_HAbs)
#define GUI_GRID_H (GUI_GRID_HAbs / 25)
#define GUI_GRID_W (GUI_GRID_WAbs / 40)

class RscPicture;
class RscFrame;
class RscTextMulti;

class RscTitles {
	class GVAR(RscDialogBox) {
		idd = 6661;
		movingEnable = 1;
		fadeIn = "true";
		fadeOut = "true";
		duration = 1e+11;
		onload = "uiNamespace setVariable ['btc_toolchain_dialog_RscDialogBox', _this select 0]";
		onunload = "";
		class ControlsBackground {
			class RscPicture_1200: RscPicture
			{
				idc = 1200;
				text = "";
				x = "(0.5 * safeZoneW + safeZoneX) - ((25 * (((safezoneW / safezoneH) min 1.2)/40)) * 0.5)";
				y = "-19 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + (safezoneY + safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))";
				w = "5 * (((safezoneW / safezoneH) min 1.2) / 40)";
				h = "5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			};
			class RscFrame_1801: RscFrame
			{
				idc = 1801;
				colorBackground[] = {0, 0, 0, 0.5};
				colorText[] = {1,1,1,1};
				text = "$STR_BTC_DIALOG_INCOMING_TRANS";
				sizeEx = "0.6 * ((((safezoneW / safezoneH) min 1.2)/1.2)/25)";
				x = "(0.5 * safeZoneW + safeZoneX) - ((25 * (((safezoneW / safezoneH) min 1.2)/40)) * 0.5)";
				y = "-20 * ((((safezoneW / safezoneH) min 1.2) / 1.2)/25) + (safezoneY + safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))";
				w = "24.5 * (((safezoneW / safezoneH) min 1.2)/40)";
				h = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2)/25)";
			};
			class RscText_1000: RscTextMulti
			{
				idc = 1000;
				text = "";
				sizeEx = "0.9 * ((((safezoneW / safezoneH) min 1.2)/1.2)/25)";
				colorBackground[] = {0, 0, 0, 0.5};
				x = "((0.5 * safeZoneW + safeZoneX) - ((15 * (((safezoneW / safezoneH) min 1.2)/40)) * 0.5))";
				y = "-19 * ((((safezoneW / safezoneH) min 1.2) / 1.2)/25) + (safezoneY + safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))";
				w = "19.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
				h = "5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			};
		};
	};
};
