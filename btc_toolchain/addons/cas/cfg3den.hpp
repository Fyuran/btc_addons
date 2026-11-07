#include "\z\btc_toolchain\addons\gui\includes\ctrlList.hpp"

class Cfg3DEN
{
	class Attributes
	{
		#include "cfg3den_forward_declarations.hpp"
		class GVAR(vehicleData): Default
		{
			idc = VEHICLE_DATA;
			onLoad = QUOTE(_this call FUNC(list_onLoad));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(list_attributeLoad));
			attributeSave = QUOTE([_this] call FUNC(list_attributeSave));
			x = QUOTE(5 * h_PIXELW);
			w = QUOTE(125 * h_PIXELW);
			h = QUOTE(36 * h_PIXELH);
			class Controls
			{
				class GVAR(class): Combo
				{
					idc = VEHICLE_CLASS;
					attributeLoad = "";
					attributeSave = "";
					class Controls: Controls
					{
						class Title: Title {
							text = "Vehicle class";
							tooltip = "Select aircraft class";
							w = QUOTE(43 * h_PIXELW);
						};
						class Value: Value 
						{
							x = QUOTE(43 * h_PIXELW);
							onLBSelChanged = QUOTE(_this call FUNC(class_onLBSelChanged));
						};
					};
				};
				class List_1: ctrlControlsGroupNoScrollbars
				{
					idc = LIST_1;
					y = QUOTE(6 * h_PIXELH);
					w = QUOTE(125 * h_PIXELW);
					h = QUOTE(30 * h_PIXELH);
					class Controls
					{
						class Title: ctrlStatic 
						{
							text = "Weapons selection";
							tooltip = "Multi-Select vehicle weapon";
							w = QUOTE(43 * h_PIXELW);
							h = QUOTE(5 * h_PIXELH);
							style = ST_RIGHT;
						};
						class Value: ctrlListbox 
						{
							idc = IDC_DISPLAY3DENEDITATTRIBUTES_VALUE;
							x = QUOTE(43 * h_PIXELW);
							w = QUOTE(82 * h_PIXELW);
							h = QUOTE(30 * h_PIXELH);
							style = LB_MULTI;
						};
					};
				};
			};
		};
	};
};
