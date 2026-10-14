#ifndef BTC_TOOLCHAIN_GUI_CTRLLISTNEDIT_HPP
#define BTC_TOOLCHAIN_GUI_CTRLLISTNEDIT_HPP

class btc_toolchain_gui_ctrlListNEdit: btc_toolchain_gui_ctrlListN
{
    class Controls: Controls
    {
        class Title: Title {};
        class Button_1: Button_1
        {
            y = QUOTE(6 * h_PIXELH);
        };
        class Button_2: Button_2
        {
            y = QUOTE(6 * h_PIXELH);
        };
        class Edit: ctrlEdit
        {
            idc = IDC_DISPLAY3DEN_EDIT;
            y = QUOTE(12 * h_PIXELH);
            w = QUOTE(40 * h_PIXELW);
            h = QUOTE(6 * h_PIXELH);
        };
        class List_Background: List_Background
        {
            y = QUOTE(18 * h_PIXELH);
            h = QUOTE(32 * h_PIXELH);
        };
        class List_Arrow_Background: List_Arrow_Background
        {
            y = QUOTE(18 * h_PIXELH);
            h = QUOTE(32 * h_PIXELH);
        };
        class ArrowLeft: ArrowLeft {};
        class ArrowRight: ArrowRight {};
        class Value: Value
        {
            y = QUOTE(18 * h_PIXELH);
            h = QUOTE(32 * h_PIXELH);
        };
    };
};

#endif
