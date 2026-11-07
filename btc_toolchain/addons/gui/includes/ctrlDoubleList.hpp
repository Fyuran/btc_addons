#ifndef BTC_TOOLCHAIN_GUI_CTRLDOUBLELIST_HPP
#define BTC_TOOLCHAIN_GUI_CTRLDOUBLELIST_HPP

class btc_toolchain_gui_ctrlDoubleList: ctrlControlsGroupNoScrollbars
{
    w = QUOTE(120 * h_PIXELW);
    h = QUOTE(60 * h_PIXELH);
    class Controls
    {
        class List_1: btc_toolchain_gui_ctrlList
        {
            w = QUOTE(60 * h_PIXELW);
            h = QUOTE(60 * h_PIXELH);
            class Controls: Controls
            {
                class Title: Title
                {
                    w = QUOTE(60 * h_PIXELW);
                    h = QUOTE(6 * h_PIXELH);
                };
                class Button_1: Button_1
                {
                    y = QUOTE(6 * h_PIXELH);
                    w = QUOTE(20 * h_PIXELW);
                    h = QUOTE(6 * h_PIXELH);
                };
                class ButtonsBackground: ctrlStaticBackground
                {
                    colorBackground[] = {0, 0, 0, 1};
                    x = QUOTE(20 * h_PIXELW);
                    y = QUOTE(6 * h_PIXELH);
                    w = QUOTE(20 * h_PIXELW);
                    h = QUOTE(6 * h_PIXELH);
                };
                class Button_2: Button_2
                {
                    x = QUOTE(40 * h_PIXELW);
                    y = QUOTE(6 * h_PIXELH);
                    w = QUOTE(20 * h_PIXELW);
                    h = QUOTE(6 * h_PIXELH);
                };
                class Value: Value
                {
                    y = QUOTE(12 * h_PIXELH);
                    w = QUOTE(60 * h_PIXELW);
                    h = QUOTE(48 * h_PIXELH);
                };
            };
        };
        class List_2: List_1
        {
            x = QUOTE(60 * h_PIXELW);
            class Controls: Controls
            {
                class Title: Title {};
                class Button_1: Button_1 {};
                class Button_2: Button_2 {};
                class Value: Value {};
            };
        };
    };
};

#endif
