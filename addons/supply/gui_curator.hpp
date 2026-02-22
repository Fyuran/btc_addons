class GVAR(RscAttributeSupply) {
	idd = CURATOR_DISPLAY;
	movingEnable = "false";
	onLoad = "params[""_display""]; [_display] call btc_supply_fnc_curator_gui;";
	class ControlsBackground {
		class Window_Grp: ctrlControlsGroupNoScrollbars {
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2))";
			y = "(safezoneY + (safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))/2)";
			w = "80 * pixelW * pixelGrid";
			h = "47 * pixelH * pixelGrid";
			class Controls {
				class Title: ctrlStaticTitle {
					w = "80 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
					text = "=BTC= Supply Module";
				};
				class Window: ctrlStaticBackground {
					y = "2 * pixelH * pixelGrid";
					w = "80 * pixelW * pixelGrid";
					h = "40 * pixelH * pixelGrid";
					colorBackground[] = {0.2, 0.2, 0.2, 1};
				};
				class Footer: ctrlStaticBackground {
					y = "42 * pixelH * pixelGrid";
					w = "80 * pixelW * pixelGrid";
					h = "3 * pixelH * pixelGrid";
					colorBackground[] = {0.1, 0.1, 0.1, 1};
				};
			};
		};
	};
	class Controls {
		class VehicleClass: ctrlControlsGroupNoScrollbars {
            x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (8 * pixelW * pixelGrid)";
			y = "5 * pixelH * pixelGrid";
			w = "30 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			idc = CLASS;
			class Controls {
				class Title: ctrlStatic {
					text = "Vehicle Class";
					style = 1;
					//colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",1};
					colorBackground[] = {0, 0, 0, 0};
					w = "10 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
				class Value: ctrlCombo {
					idc = COMBO;
					x = "10 * pixelW * pixelGrid";
					w = "20 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
			};
		};
		class AllowDamage: ctrlControlsGroupNoScrollbars {
            x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (8 * pixelW * pixelGrid)";
			y = "8 * pixelH * pixelGrid";
			w = "30 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			idc = ALLOW_DAMAGE;
			class Controls {
				class Title: ctrlStatic {
					text = "Allow Damage";
					style = 1;
					//colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",1};
					colorBackground[] = {0, 0, 0, 0};
					w = "10 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
				class Value: ctrlCheckboxBaseline {
					idc = CHECKBOX;
					x = "10 * pixelW * pixelGrid";
					w = "2 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
			};
		};
		class Presets: ctrlButton {
			idc = -1;
			onButtonClick = "[ctrlParent (_this#0)] call btc_supply_fnc_presets_init;";
			text = "Presets";
			colorBackground[] = {0.13, 0.47, 0.30, 1};
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (50 * pixelW * pixelGrid)";
			y = "5 * pixelH * pixelGrid";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Main: ctrlControlsGroupNoScrollbars {
			idc = MAIN;
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (8 * pixelW * pixelGrid)";
			y = "12 * pixelH * pixelGrid";
			w = "((40 + 80) + 15) * (pixelW * pixelGrid * 0.50)";
			h = "60 * (pixelH * pixelGrid * 0.50)";
			class Controls {
				class Grp1: GVAR(ctrlGrp) {
					idc = GROUP_1;
					class Controls: Controls {
						class Edit: Edit {
							idc = EDIT_1;
						};
						class Add: Add {
							idc = ADD_1;
						};
						class Remove: Remove {
							idc = REMOVE_1;
						};
						class List: List {
							idc = LIST_1;
						};
						class Title: Title {
							text = "Objects List";
						};
					};
				};
				class Grp2: GVAR(ctrlGrp_ListN) {
					idc = GROUP_2;
					x = "(40 + 5) * (pixelW * pixelGrid * 0.50)";
					class Controls: Controls {
						class Edit: Edit {
							idc = EDIT_2;
						};
						class Add: Add {
							idc = ADD_2;
						};
						class Remove: Remove {
							idc = REMOVE_2;
						};
						class ArrowLeft: ArrowLeft {
							idc = ARROWLEFT;
						};
						class ArrowRight: ArrowRight {
							idc = ARROWRIGHT;
						};
						class List: List {
							idcLeft = ARROWLEFT;
							idcRight = ARROWRIGHT;
							idc = LIST_2;
						};
						class Title: Title {
							text = "Supplies List";
						};
						class List_Background1: List_Background1 {
							idc = -1;
						};
						class List_Background2: List_Background2 {
							idc = -1;
						};
					};
				};
			};
		};
		class Footer: ctrlControlsGroupNoScrollbars {
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (59 * pixelW * pixelGrid)";
			y = "42.5 * pixelH * pixelGrid";
			w = "60 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			idc = FOOTER;
			class Controls {
				class OK: ctrlButton {
                    idc = FOOTER_OK;
					text = "CONFIRM";
					x = "0";
					w = "10 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
				class Cancel: ctrlButton {
                    idc = FOOTER_ABORT;
					text = "ABORT";
					x = "10.5 * pixelW * pixelGrid";
					w = "10 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
			};
		};
	};
};
