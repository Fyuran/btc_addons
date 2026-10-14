#ifndef BTC_TOOLCHAIN_GUI_CTRLLIST_HPP
#define BTC_TOOLCHAIN_GUI_CTRLLIST_HPP

class btc_toolchain_gui_ctrlList: ctrlControlsGroupNoScrollbars
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
        class Value: ctrlListbox
        {
            idc = IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
            y = QUOTE(12 * h_PIXELH);
            w = QUOTE(40 * h_PIXELW);
            h = QUOTE(38 * h_PIXELH);
        };
    };
};

#endif
