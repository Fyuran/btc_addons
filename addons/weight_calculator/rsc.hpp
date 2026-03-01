/* #Catope
$[
    1.063,
    ["btc_toolchain_weight_calculator",[["(safeZoneX + (GUI_GRID_CENTER_W - ((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2)) / 2)","(safeZoneY + (GUI_GRID_CENTER_H - (((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2) / 1.2)) / 2)","((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2)","(((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2) / 1.2)"],"(((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2) / 40)","((((GUI_GRID_CENTER_W / GUI_GRID_CENTER_H) min 1.2) / 1.2) / 25)","GUI_GRID_CENTER"],0,0,0],
    [1000,"RscText_1004: btc_toolchain_weight_calculator_RscText",[1,"Class",["0.388625 * GUI_GRID_CENTER_X","0.247 * GUI_GRID_CENTER_Y","0.086625 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],[0,0,0,0.7],[-1,-1,-1,-1],"","-1"],["idc = 1004;"]],
    [1001,"RscText_1003: btc_toolchain_weight_calculator_RscText",[1,"Name",["0.302 * GUI_GRID_CENTER_X","0.247 * GUI_GRID_CENTER_Y","0.086625 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],[0,0,0,0.7],[-1,-1,-1,-1],"","-1"],["idc = 1003;"]],
    [1002,"RscText_1002: btc_toolchain_weight_calculator_RscText",[1,"Per unit",["0.47525 * GUI_GRID_CENTER_X","0.247 * GUI_GRID_CENTER_Y","0.086625 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],[0,0,0,0.7],[-1,-1,-1,-1],"","-1"],["idc = 1002;"]],
    [1003,"RscText_1001: btc_toolchain_weight_calculator_RscText",[1,"Total",["0.561875 * GUI_GRID_CENTER_X","0.247 * GUI_GRID_CENTER_Y","0.086625 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],[0,0,0,0.7],[-1,-1,-1,-1],"","-1"],["idc = 1001;"]],
    [1004,"RscText_1000: btc_toolchain_weight_calculator_RscText",[1,"Gear weight data",["0.314375 * GUI_GRID_CENTER_X","0.225 * GUI_GRID_CENTER_Y","0.297 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],["(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",0.5],[-1,-1,-1,-1],"","-1"],["font = |PuristaBold|;","idc = 1000;"]],
    [2100,"RscCombo_2100",[1,"",["0.611375 * GUI_GRID_CENTER_X","0.225 * GUI_GRID_CENTER_Y","0.037125 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],["(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",0.5],[-1,-1,-1,-1],"","-1"],["idc = 2100;"]],
    [1005,"RscListbox_1500: btc_toolchain_weight_calculator_RscListBox",[1,"",["0.302 * GUI_GRID_CENTER_X","0.269 * GUI_GRID_CENTER_Y","0.3465 * GUI_GRID_CENTER_W","0.506 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],[0,0,0,0.7],[-1,-1,-1,-1],"","-1"],["idc = 1500;"]],
    [1600,"",[1,"X",["0.302 * GUI_GRID_CENTER_X","0.225 * GUI_GRID_CENTER_Y","0.012375 * GUI_GRID_CENTER_W","0.022 * GUI_GRID_CENTER_H"],[-1,-1,-1,-1],["(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",0.5],[-1,-1,-1,-1],"","-1"],["font = |PuristaBold|;"]]
]
*/

#include "\a3\ui_f\hpp\definecommoncolors.inc"
#include "\a3\ui_f\hpp\defineresincl.inc"
#include "\a3\ui_f\hpp\definecommongrids.inc"

class RscButton;
class RscText;
class RscListNBox;
class RscFrame;

class GVAR(calculator_RscButton): RscButton {
    font = "RobotoCondensedBold";
    colorText[] = GUI_TEXT_COLOR;
    colorBackground[] = GUI_BCG_MENU;
};
class GVAR(calculator_RscText): RscText {
    font = "RobotoCondensed";
    colorText[] = GUI_TEXT_COLOR;
    colorBackground[] = GUI_BCG_MENU;
};

class GVAR(calculator_RscListNBox): RscListNBox {
    colorText[] = GUI_TEXT_COLOR;
    colorSelect[] = GUI_TEXT_COLOR;
    colorSelect2[] = GUI_TEXT_COLOR;
    colorSelectBackground[] = {0.95, 0.95, 0.95, 0};
    colorSelectBackground2[] = {1, 1, 1, 0};
    font = "RobotoCondensed";
    columns[] = {
        "0",
        "0.36",
        "0.54",
        "0.72"};
    class Items {
        class Name {
            text = "Name";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };

        class Count {
            text = "Count";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };
        class Weight {
            text = "Weight x unit";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };

        class TotalWeight {
            text = "Total weight";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };
    };
};

class GVAR(calculator)
{
    idd = 751993;
    class ControlsBackground {
        class RscText_1001 : GVAR(calculator_RscText) {
            colorBackground[] = GUI_BCG_MENU;
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW";
            h = "0.51 * safezoneH";
        };

        class RscText_1002 : GVAR(calculator_RscText) {
            idc = 1002;
            x = "0.685625 * safezoneW + safezoneX";
            y = "0.247 * safezoneH + safezoneY";
            w = "0.06187 * safezoneW";
            h = "0.022 * safezoneH";
            colorBackground[] = GUI_BCG_COLOR_SELECTED;
        };

        class RscFrame_2000 : RscFrame {
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW";
            h = "0.51 * safezoneH";
        };

        class RscText_1000 : GVAR(calculator_RscText) {
            text = "Gear Weight Calculator";
            font = "PuristaBold";
            x = "0.264875 * safezoneW + safezoneX";
            y = "0.247 * safezoneH + safezoneY";
            w = "0.4205 * safezoneW";
            h = "0.022 * safezoneH";
            colorBackground[] = GUI_BCG_COLOR_SELECTED;
        };
    };
    class Controls {
        class RscListNBox_1500 : GVAR(calculator_RscListNBox) {
            idc = 1500;
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW;";
            h = "0.506 * safezoneH";
        };
		
        class RscButton_1000 : GVAR(calculator_RscButton) {
            onButtonClick = "closeDialog 2";
            text = "X";
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.247 * safezoneH + safezoneY";
            w = "0.012375 * safezoneW";
            h = "0.022 * safezoneH";
            colorBackground[] = GUI_BCG_COLOR_SELECTED;
        };
    };
};
