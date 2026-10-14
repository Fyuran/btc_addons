#ifndef BTC_TOOLCHAIN_GUI_CTRLLISTN_HPP
#define BTC_TOOLCHAIN_GUI_CTRLLISTN_HPP

class btc_toolchain_gui_ctrlListN: ctrlControlsGroupNoScrollbars
{
    w = QUOTE(40 * h_PIXELW);
    h = QUOTE(50 * h_PIXELH);
    class Controls
    {
        class Title: ctrlStaticTitle
        {
            colorBackground[]= GUI_BCG_COLOR;
            idc = IDC_DISPLAY3DENEDITATTRIBUTES_TITLE;
            style = ST_CENTER;
            text = "Title";
            w = QUOTE(40 * h_PIXELW);
            h = QUOTE(6 * h_PIXELH);
        };
        class Button_1: ctrlButton
        {
            idc = 1600;
            text = "Button_1";
            y = QUOTE(6 * h_PIXELH);
            w = QUOTE(20 * h_PIXELW);
            h = QUOTE(6 * h_PIXELH);
        };
        class Button_2: ctrlButton
        {
            idc = 1601;
            text = "Button_2";
            x = QUOTE(20 * h_PIXELW);
            y = QUOTE(6 * h_PIXELH);
            w = QUOTE(20 * h_PIXELW);
            h = QUOTE(6 * h_PIXELH);
        };
        class List_Background: ctrlStaticBackground
        {
            colorBackground[] = {0,0,0,0.5};
            y = QUOTE(12 * h_PIXELH);
            w = QUOTE(25 * h_PIXELW);
            h = QUOTE(38 * h_PIXELH);
        };
        class List_Arrow_Background: ctrlStaticBackground
        {
            colorBackground[] = {0,0,0,0.7};
            x = QUOTE(25 * h_PIXELW);
            y = QUOTE(12 * h_PIXELH);
            w = QUOTE(15 * h_PIXELW);
            h = QUOTE(38 * h_PIXELH);
        };
        class ArrowLeft: ctrlButton
        {
            idc = 992;
            text = "-";
        };
        class ArrowRight: ctrlButton
        {
            idc = 993;
            text = "+";
        };
        class Value: ctrlListNBox
        {
            idc = IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
            idcLeft = 992;
            idcRight = 993;
            drawSideArrows = 1;
            rowHeight = QUOTE(4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.5);
            columns[] = {QUOTE(5 * PIXELW_SCALED(1)), QUOTE(35 * PIXELW_SCALED(1))};
            y = QUOTE(12 * h_PIXELH);
            w = QUOTE(40 * h_PIXELW);
            h = QUOTE(38 * h_PIXELH);
        };
    };
};

#endif
