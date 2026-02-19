class GVAR(RscPresets) {
    idd = PRESETS;
    movingEnable = "true";
    class controlsBackground {
		class GVAR(window): ctrlControlsGroupNoScrollbars {
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2))";
			y = "(safezoneY + (safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))/2)";
			w = "40 * pixelW * pixelGrid";
			h = "90 * pixelH * pixelGrid";
			class Controls {
				class Window: ctrlStaticBackground {
					y = "2 * pixelH * pixelGrid";
					w = "40 * pixelW * pixelGrid";
					h = "80 * pixelH * pixelGrid";
					colorBackground[] = {0.2, 0.2, 0.2, 1};
				};
				class Footer: ctrlStaticBackground {
					y = "82 * pixelH * pixelGrid";
					w = "40 * pixelW * pixelGrid";
					h = "3 * pixelH * pixelGrid";
					colorBackground[] = {0.1, 0.1, 0.1, 1};
				};
			};
		};
    };
    class Controls {
		class Title: ctrlStaticTitle {
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2))";
			w = "40 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			text = "=BTC= Supply Module Presets";
			moving = "true";
		};
		class Close: ctrlButton {
			text = "X";
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) + (38 * pixelW * pixelGrid)";
			w = "2 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			onButtonClick = "(ctrlParent (_this#0)) closeDisplay 2;";
			//onButtonClick = "CloseDialog 1;";
		};
        class List: ctrlListBox {
            idc = PRESETS_LIST;
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) +  (2.5 * pixelW * pixelGrid)";
            y = "2 * pixelH * pixelGrid";
            w = "35 * pixelW * pixelGrid";
            h = "80 * pixelH * pixelGrid";
        };
        class Footer: ctrlControlsGroupNoScrollbars {
			x = "((safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)) +  (1 * pixelW * pixelGrid)";
			y = "82.5 * pixelH * pixelGrid";
			w = "40 * pixelW * pixelGrid";
			h = "2 * pixelH * pixelGrid";
			idc = FOOTER;
			class Controls {
				class Load: ctrlButton {
                    idc = PRESETS_LOAD;
					text = "LOAD";
					w = "8 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
				class Delete: ctrlButton {
					idc = PRESETS_DELETE;
					text = "DELETE";
					x = "8.5 * pixelW * pixelGrid";
					w = "8 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
				class Save: ctrlButton {
					idc = PRESETS_SAVE;
					text = "SAVE";
					x = "17 * pixelW * pixelGrid";
					w = "8 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
                class Edit: ctrlEdit {
                    idc = PRESETS_EDIT;
					x = "25 * pixelW * pixelGrid";
					w = "13 * pixelW * pixelGrid";
					h = "2 * pixelH * pixelGrid";
				};
			};
		};
    };
};
