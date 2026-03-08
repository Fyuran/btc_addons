#define GUI_GRID_WAbs ((safezoneW / safezoneH) min 1.2)
#define GUI_GRID_HAbs (GUI_GRID_WAbs / 1.2)
#define GUI_GRID_X safezoneX
#define GUI_GRID_Y (safezoneY + safezoneH - GUI_GRID_HAbs)
#define GUI_GRID_H (GUI_GRID_HAbs / 25)
#define GUI_GRID_W (GUI_GRID_WAbs / 40)

class RscPicture;
class RscText;

class RscTitles {
    class btc_toolchain_lift_hud {
        idd = 1000;
        movingEnable=0;
        duration=1e+011;
        name = "btc_toolchain_lift_hud";
        onLoad = "uiNamespace setVariable [""btc_toolchain_lift_hud"", _this select 0];";
        class controls {
            class Radar_background_RscPicture_1001 : RscPicture {
                idc = 1001;
                x = "0.82 * safezoneW + safezoneX";
                y = "0.75 * safezoneH + safezoneY";
                w = "0.14 * safezoneW";
                h = "0.14 * safezoneH * (getresolution select 4)";
                colorText[] = {0.1, 0.1, 0.1, 0.6};
                text = "\A3\ui_f\data\igui\rscingameui\rscminimap\gradient_gs.paa";
            };
            class Radar_RscPicture_1002 : RscPicture {
                idc = 1002;
                x = "0.82 * safezoneW + safezoneX";
                y = "0.75 * safezoneH + safezoneY";
                w = "0.14 * safezoneW";
                h = "0.14 * safezoneH * (getresolution select 4)";
                text = "\A3\Ui_f\data\GUI\Rsc\RscSlingLoadAssistant\SLA_Circles_ca.paa";
            };
            class Crosshair_RscPicture_1003 : RscPicture {
                idc = 1003;
                x = "0.85 * safezoneW + safezoneX";
                y = "0.85 * safezoneH + safezoneY";
                w = "0.025 * safezoneW";
                h = "0.025 * safezoneH * (getresolution select 4)";
                colorText[] = {1, 0, 0, 1};
                text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa";
            };
            class Pic_Obj_RscPicture_1004 : RscPicture {
                idc = 1004;
                x = "0.822 * safezoneW + safezoneX";
                y = "0.75 * safezoneH + safezoneY";
                w = "0.03 * safezoneW";
                h = "0.03 * safezoneH";
            };
            class Arrow_RscPicture_1005 : RscPicture {
                idc = 1005;
                x = "0.94 * safezoneW + safezoneX";
                y = "0.75 * safezoneH + safezoneY";
                w = "0.02 * safezoneW";
                h = "0.02 * safezoneH * (getresolution select 4)";
            };
            class Type_Obj_RscText_1006 : RscText {
                idc = 1006;
                font = "PuristaMedium";
                sizeEx = "0.8 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                x = "0.84 * safezoneW + safezoneX";
                y = "0.68 * safezoneH + safezoneY";
                w = "0.3 * safezoneW";
                h = "0.1 * safezoneH";
            };
            class Alt_Obj_RscText_1007 : RscText {
                idc = 1007;
                font = "PuristaMedium";
                sizeEx = "0.8 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
                x = "0.92 * safezoneW + safezoneX";
                y = "0.935 * safezoneH + safezoneY";
                w = "0.3 * safezoneW";
                h = "0.1 * safezoneH";
            };
        };
    };
};
