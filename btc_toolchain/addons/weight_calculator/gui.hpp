class GVAR(calculator_RscButton): RscButton
{
    font = "RobotoCondensedBold";
    colorText[] = GUI_TEXT_COLOR;
    colorBackground[] = GUI_BCG_MENU;
};
class GVAR(calculator_RscText): RscText
{
    font = "RobotoCondensed";
    colorText[] = GUI_TEXT_COLOR;
    colorBackground[] = GUI_BCG_MENU;
};

class GVAR(calculator_RscListNBox): RscListNBox
{
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
    class Items
    {
        class Name
        {
            text = "Name";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };

        class Count
        {
            text = "Count";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };
        class Weight
        {
            text = "Weight x unit";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };

        class TotalWeight
        {
            text = "Total weight";
            value = -1;
            color[] = GUI_BCG_DARK_COLOR;
        };
    };
};

class GVAR(calculator)
{
    idd = 751993;
    class ControlsBackground
    {
        class RscText_1001 : GVAR(calculator_RscText)
        {
            colorBackground[] = GUI_BCG_MENU;
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW";
            h = "0.51 * safezoneH";
        };

        class RscText_1002 : GVAR(calculator_RscText)
        {
            idc = 1002;
            x = "0.685625 * safezoneW + safezoneX";
            y = "0.247 * safezoneH + safezoneY";
            w = "0.06187 * safezoneW";
            h = "0.022 * safezoneH";
            colorBackground[] = GUI_BCG_COLOR_SELECTED;
        };

        class RscFrame_2000 : RscFrame
        {
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW";
            h = "0.51 * safezoneH";
        };

        class RscText_1000 : GVAR(calculator_RscText)
        {
            text = "Gear Weight Calculator";
            font = "PuristaBold";
            x = "0.264875 * safezoneW + safezoneX";
            y = "0.247 * safezoneH + safezoneY";
            w = "0.4205 * safezoneW";
            h = "0.022 * safezoneH";
            colorBackground[] = GUI_BCG_COLOR_SELECTED;
        };
    };
    class Controls
    {
        class RscListNBox_1500 : GVAR(calculator_RscListNBox)
        {
            idc = 1500;
            x = "0.2525 * safezoneW + safezoneX";
            y = "0.269 * safezoneH + safezoneY";
            w = "0.495 * safezoneW;";
            h = "0.506 * safezoneH";
        };
		
        class RscButton_1000 : GVAR(calculator_RscButton)
        {
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
