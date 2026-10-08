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
		
		class GVAR(wp_type): Type 
		{
			idc = WP_TYPE;
			onLoad = QUOTE(_this call FUNC(type_onLoad));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(type_attributeLoad));
			attributeSave = QUOTE(_this call FUNC(type_attributeSave));
			class Controls: Controls
			{
				class Title: Title {};
				class Search: Search {};
				class SearchButton: SearchButton {};
				class Value: Value 
				{
					onTreeSelChanged = QUOTE(_this call FUNC(type_onTreeSelChanged));
				};
			};
		};
		class GVAR(side): Combo
		{
			idc = SIDE_GRP;
			onLoad = QUOTE(_this call FUNC(side_combo_onLoad));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value {};
			};
		};
		class GVAR(timeout): Edit
		{
			idc = TIMEOUT;
			onLoad = QUOTE(_this call FUNC(timeout_onLoad));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value 
				{
					maxChars = 4;
				};
			};
		};
		class GVAR(seek_end): Checkbox
		{
			idc = SEEK_END;
			onLoad = QUOTE(_this call FUNC(seek_checkbox_onLoad));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value {};
			};
		};
		class GVAR(CombatModeWaypoint) : CombatModeWaypoint
		{
			idc = COMBATMODE;
		};
		class GVAR(BehaviourWaypoint): BehaviourWaypoint
		{
			idc = BEHAVIOR;
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(behavior_attributeLoad));
			//attributeSave = QUOTE(_ctrl = _this controlsGroupCtrl 100; _value = _ctrl lbValue (lbCurSel _ctrl));
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value {};
			};
		};
		class GVAR(FormationWaypoint): FormationWaypoint
		{
			idc = FORMATION_WP;
			attributeLoad = "(_this controlsGroupCtrl 100) lbSetCurSel (['no change','wedge','vee','line','column','file','stag_column','ech_left','ech_right','diamond'] find _value);";
			attributeSave = "_ctrl = _this controlsGroupCtrl 100; _value = _ctrl lbValue (lbCurSel _ctrl); ['no change','wedge','vee','line','column','file','stag_column','ech_left','ech_right','diamond'] select _value;";
			onLoad = QUOTE(_ctrl = (_this#0) controlsGroupCtrl 100; uiNamespace setVariable[ARR_2(QQGVAR(formation),_ctrl)]);
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value
				{

					values[]={0,1,2,3,4,5,6,7,8,9};
					onToolboxSelChanged="";
				};
			};
		};
		class GVAR(SpeedModeWaypoint): SpeedModeWaypoint
		{
			idc = SPEED;
			//onLoad = QUOTE(_this call FUNC(speed_onLoad));
			attributeLoad = QUOTE((_this controlsGroupCtrl 100) lbSetCurSel ([ARR_4('unchanged','limited','normal','full')] find _value));
			attributeSave = QUOTE(_ctrl = _this controlsGroupCtrl 100; _value = _ctrl lbValue (lbCurSel _ctrl); [ARR_4('unchanged','limited','normal','full')] select _value);
			class Controls: Controls
			{
				class Title: Title {};
				class Value: Value
				{
					onToolboxSelChanged = "";
					values[]={0, 1, 2, 3};
				};
			};
		};
		class GVAR(File): Edit
		{
			idc = FILE;
		};
		class GVAR(completion_radius): Edit
		{
			idc = COMPLETION_RADIUS;
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
							text = "Waves";
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
							y = QUOTE(18.5 * h_PIXELH);
							h = QUOTE(31.5 * h_PIXELH);
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
							text = "Classes";
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
