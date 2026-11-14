class GVAR(gui) 
{
	idd = GUI_IDD;
	enableSimulation = 1;
	onLoad = "";
	onUnload = "";
	movingEnable = 0;
	class Controls 
	{
        class Group_1: ctrlControlsGroupNoScrollbars
        {
            idc = GROUP_1_IDC;
            x = QUOTE((safeZoneW - (100 * PIXELW)) * 0.5 + safeZoneX);
            y = QUOTE((safeZoneH - (20 * PIXELH)) * 0.9 + safeZoneY);
            w = QUOTE(100 * PIXELW);
            h = QUOTE(20 * PIXELH);
            class Controls 
            {
                class List: ctrlListbox
                {
                    idc = LIST_IDC;
                    x = 0;
                    y = 0;
                    w = QUOTE(80 * PIXELW);
                    h = QUOTE(20 * PIXELH);
                };
                class Image: ctrlStaticPicture
                {
                    idc = PICTURE_IDC;
                    text = "";
                    x = QUOTE(80 * PIXELW);
                    y = 0;
                    w = QUOTE(20 * PIXELW);
                    h = QUOTE(20 * PIXELH);
                };
            };
        };
	};
};
