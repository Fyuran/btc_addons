#ifndef BTC_TOOLCHAIN_GUI_CTRLLISTEDITPRESETS_HPP
#define BTC_TOOLCHAIN_GUI_CTRLLISTEDITPRESETS_HPP

class btc_toolchain_gui_ctrlListEditPresets: btc_toolchain_gui_ctrlListEdit 
{
    h = QUOTE(56 * h_PIXELH);
    class Controls: Controls 
    {    
        class Presets: ctrlButton
        {
            idc = 10001;
            w = QUOTE(40 * h_PIXELW);
            h = QUOTE(6 * h_PIXELH);
            text = "PRESETS";
            colorBackground[] = {0.13, 0.47, 0.30, 1};
            style = ST_CENTER;
        };
        class Title: Title
        {
            y = QUOTE(6.5 * h_PIXELH);
        };
        class Button_1: Button_1
        {
            y = QUOTE(12.5 * h_PIXELH);
        };
        class Button_2: Button_2
        {
            y = QUOTE(12.5 * h_PIXELH);
        };
        class Edit: Edit
        {
            idc = IDC_DISPLAY3DEN_EDIT;
            y = QUOTE(18.5 * h_PIXELH);
        };
        class Value: Value
        {
            y = QUOTE(24.5 * h_PIXELH);
            h = QUOTE(25.5 * h_PIXELH);
        };
    };
};

#endif
