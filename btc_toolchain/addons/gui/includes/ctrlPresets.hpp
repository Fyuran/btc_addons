#ifndef BTC_TOOLCHAIN_GUI_CTRLPRESETS_HPP
#define BTC_TOOLCHAIN_GUI_CTRLPRESETS_HPP

class btc_toolchain_gui_ctrlPresets: ctrlControlsGroupNoScrollbars
{
	idc = PRESETS;
	onKillFocus = QUOTE((_this#0) ctrlShow false);
	x = QUOTE(10 * h_PIXELW);
	w = QUOTE(80 * h_PIXELW);
	h = QUOTE(100 * h_PIXELH);
	moving = 1;
	class Controls
	{
		class Title: ctrlStaticTitle
		{
			text = "Presets";
			idc = PRESETS_TITLE;
			style = ST_CENTER;
			w = QUOTE(80 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
		class List: ctrlListbox
		{
			idc = PRESETS_VALUE;
			onLBSelChanged = QUOTE(_this call btc_toolchain_gui_fnc_presets_lbSelChanged);
			colorBackground[] = {0.2, 0.2, 0.2, 1};
			y = QUOTE(6 * h_PIXELH);
			w = QUOTE(80 * h_PIXELW);
			h = QUOTE(76 * h_PIXELH);
		};
		class Edit: ctrlEdit
		{
			idc = PRESETS_EDIT;
			colorBackground[] = {0, 0, 0, 1};
			y = QUOTE(82 * h_PIXELH);
			w = QUOTE(80 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
		class Close: ctrlButton
		{
			idc = PRESETS_CLOSE;
			text = "CLOSE";
			onButtonClick = QUOTE(_this call btc_toolchain_gui_fnc_presets_close);
			colorBackground[] = {GUI_BCG_ERROR_RGB, 1};
			y = QUOTE(88 * h_PIXELH);
			w = QUOTE(20 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
		class Load: ctrlButton
		{
			idc = PRESETS_LOAD;
			text = "LOAD";
			onButtonClick = QUOTE(_this call btc_toolchain_gui_fnc_presets_load);
			x = QUOTE(20 * h_PIXELW);
			y = QUOTE(88 * h_PIXELH);
			w = QUOTE(20 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
		class Delete: ctrlButton
		{
			idc = PRESETS_DELETE;
			text = "DELETE";
			onButtonClick = QUOTE(_this call btc_toolchain_gui_fnc_presets_delete);
			x = QUOTE(40 * h_PIXELW);
			y = QUOTE(88 * h_PIXELH);
			w = QUOTE(20 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
		class Save: ctrlButton
		{
			idc = PRESETS_SAVE;
			text = "SAVE";
			onButtonClick = QUOTE(_this call btc_toolchain_gui_fnc_presets_save);
			x = QUOTE(60 * h_PIXELW);
			y = QUOTE(88 * h_PIXELH);
			w = QUOTE(20 * h_PIXELW);
			h = QUOTE(6 * h_PIXELH);
		};
	};
};

#endif
