//do not change order or the whole world will explode
#include "\z\btc_toolchain\addons\gui\includes\ctrlList.hpp"
#include "\z\btc_toolchain\addons\gui\includes\ctrlListEdit.hpp"
#include "\z\btc_toolchain\addons\gui\includes\ctrlListN.hpp"
#include "\z\btc_toolchain\addons\gui\includes\ctrlListNEdit.hpp"
#include "\z\btc_toolchain\addons\gui\includes\ctrlListEditPresets.hpp"
#include "\z\btc_toolchain\addons\gui\includes\ctrlPresets.hpp"

class Cfg3DEN
{
	class Attributes
	{
		#include "cfg3den_forward_declarations.hpp"

		class GVAR(vehicleClass): Combo
		{
			idc = VEHICLE_CLASS;
			onLoad = QUOTE(_this call FUNC(combo_onLoad));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(combo_attributeLoad));
			attributeSave = QUOTE([_this] call FUNC(combo_attributeSave));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value {};
			};
		};
		class GVAR(enableDamage): Checkbox 
		{
			idc = ALLOW_DAMAGE;
			onLoad = QUOTE(_this call FUNC(enableDamage_onLoad));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value {};
			};
		};
		class GVAR(presets): ctrlControlsGroupNoScrollbars
		{
			idc = LIST_MAIN;
			onLoad = QUOTE(_this call FUNC(list_onLoad)); //_this is already an array
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(list_attributeLoad));
			attributeSave = QUOTE([_this] call FUNC(list_attributeSave));
			x = QUOTE(5 * h_PIXELW);
			w = QUOTE(125 * h_PIXELW);
			h = QUOTE(56 * h_PIXELH);
			class Controls
			{
				class List_1: EGVAR(gui,ctrlListEditPresets)
				{
					idc = LIST_1;
					class Controls: Controls
					{
						class Presets: Presets
						{
							idc = PRESETS_BTN;
							onButtonClick = QUOTE(_this call FUNC(presets_open));
						};
						class Title: Title
						{
							idc = TITLE_1;
							text = "Container Classes";
						};
						class Edit: Edit
						{
							idc = EDIT_1;
						};
						class Button_1: Button_1
						{
							idc = BUTTON_1;
							text = "Add";
							onButtonClick = QUOTE(_this call FUNC(list_grp1_add));
						};
						class Button_2: Button_2
						{
							idc = BUTTON_2;
							text = "Remove";
							onButtonClick = QUOTE(_this call FUNC(list_grp1_remove));
						};
						class Value: Value
						{
							idc = VALUE_1;
							onLBSelChanged = QUOTE(_this call FUNC(list_grp1_LBSelChanged));
						};
					};
				};
				class List_2: EGVAR(gui,ctrlListNEdit)
				{
					idc = LIST_2;
					x = QUOTE(45 * h_PIXELW);
					y = QUOTE(6.5 * h_PIXELH);
					w = QUOTE(80 * h_PIXELW);
					class Controls: Controls
					{
						class Title: Title
						{
							idc = TITLE_2;
							text = "Supplies";
							w = QUOTE(80 * h_PIXELW);
						};
						class Edit: Edit
						{
							idc = EDIT_2;
							w = QUOTE(80 * h_PIXELW);
						};
						class Button_1: Button_1
						{
							idc = BUTTON_1_2;
							text = "Add";
							onButtonClick = QUOTE(_this call FUNC(list_grp2_add));
						};
						class Buttons_MidBackground: ctrlStaticBackground
						{
							colorBackground[] = {0, 0, 0, 1};
							x = QUOTE(20 * h_PIXELW);
							y = QUOTE(6 * h_PIXELH);
							w = QUOTE(40 * h_PIXELW);
							h = QUOTE(6 * h_PIXELH);
						};
						class Button_2: Button_2
						{
							idc = BUTTON_2_2;
							text = "Remove";
							onButtonClick = QUOTE(_this call FUNC(list_grp2_remove));
							x = QUOTE(60 * h_PIXELW);
						};
						class List_Background: List_Background
						{
							w = QUOTE(65 * h_PIXELW);
							h = QUOTE(25.5 * h_PIXELH);
						};
						class List_Arrow_Background: List_Arrow_Background
						{
							x = QUOTE(65 * h_PIXELW);
							h = QUOTE(25.5 * h_PIXELH);
							w = QUOTE(15 * h_PIXELW);
						};
						class ArrowLeft: ArrowLeft
						{
							idc = ARROWLEFT;
							onButtonClick = QUOTE([ARR_3(_this#0,false,FUNC(list_grp2_onAdjust))] call EFUNC(gui,list_arrowAdjust));
						};
						class ArrowRight: ArrowRight
						{
							idc = ARROWRIGHT;
							onButtonClick = QUOTE([ARR_3(_this#0,true,FUNC(list_grp2_onAdjust))] call EFUNC(gui,list_arrowAdjust));
						};
						class Value: Value
						{
							idc = VALUE_2;
							idcLeft = ARROWLEFT;
            				idcRight = ARROWRIGHT;
							columns[] = {QUOTE(5 * PIXELW_SCALED(1)), QUOTE(75 * PIXELW_SCALED(1))};
							w = QUOTE(80 * h_PIXELW);
							h = QUOTE(25.5 * h_PIXELH);
						};
					};
				};
			};
		};
	};
};
