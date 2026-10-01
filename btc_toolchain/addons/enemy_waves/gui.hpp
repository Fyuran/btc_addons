class GVAR(ctrlGrp): ctrlControlsGroupNoScrollbars {
	w = "40 * (pixelW * pixelGrid * 0.50)";
	h = "60 * (pixelH * pixelGrid * 0.50)";
	class Controls {
		class Title: ctrlStaticTitle {
			style = 2;
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Add: ctrlButton {
			text = "Add";
			y = "5 * (pixelH * pixelGrid * 0.50)";
			w = "20 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Remove: ctrlButton {
			text = "Remove";
			x = "20 * (pixelW * pixelGrid * 0.50)";
			y = "5 * (pixelH * pixelGrid * 0.50)";
			w = "20 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class List: ctrlListbox {
			y = "10 * (pixelH * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "45 * (pixelH * pixelGrid * 0.50)";
			style = "0x02 + 0x10";
		};
	};
};
class EGVAR(supply,ctrlGrp_ListN): ctrlControlsGroupNoScrollbars {
	class Controls {
		class Title: ctrlStaticTitle {};
		class Edit: ctrlEdit {};
		class Add: ctrlButton {};
		class Remove: ctrlButton {};
		class ArrowLeft: ctrlButton {};
		class ArrowRight: ctrlButton {};
		class List: ctrlListNBox {};
		class List_Background1: ctrlStaticBackground {};
		class List_Background2: ctrlStaticBackground {};
	};
};

class Cfg3DEN {
	class Attributes {
		class Default;
		class Title: Default {
			class Controls {
				class Title: ctrlStatic {};
			};
		};
		class Combo: Title {
			class Controls: Controls {
				class Title: Title {};
				class Value: ctrlCombo {};
			};
		};
		class Checkbox: Title {
			class Controls: Controls {
				class Title: Title {};
				class Value: ctrlCheckboxBaseline {};
			};
		};
		class Edit: Title {
			class Controls: Controls {
				class Title: Title {};
				class Value: ctrlEdit {};
			};
		};
		class GVAR(side): Combo {
			onLoad = QUOTE(_this call FUNC(side_combo_init));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(side_combo_load));
			attributeSave = QUOTE(_this call FUNC(side_combo_save));
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = SIDE_COMBO;
				};
			};
		};
		class GVAR(timeout): Edit {
			onLoad = QUOTE(_this call FUNC(timeout_init));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(timeout_load));
			attributeSave = QUOTE(_this call FUNC(timeout_save));
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = TIMEOUT_EDIT;
					maxChars = 4;
				};
			};
		};
		class GVAR(formation): Combo {
			onLoad = QUOTE(_this call FUNC(formation_combo_init));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(formation_combo_load));
			attributeSave = QUOTE(_this call FUNC(formation_combo_save));
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = FORMATION_COMBO;
				};
			};
		};
		class GVAR(presets): Title {
			x = "5 * (pixelW * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
			class Controls: Controls {
				class Presets: ctrlButton {
					idc = -1;
					onButtonClick = QUOTE([] call FUNC(presets_init));
					text = "Presets";
					colorBackground[] = {0.13, 0.47, 0.30, 1};
					w = "40 * (pixelW * pixelGrid * 0.50)";
					h = "5 * (pixelH * pixelGrid * 0.50)";
				};
			};
		};
		class GVAR(list): Title {
			onLoad = QUOTE(_this call FUNC(list_init));
			attributeLoad = QUOTE([ARR_2(_this,_value)] call FUNC(list_load));
			attributeSave = QUOTE([] call FUNC(list_save));
			x = "5 * (pixelW * pixelGrid * 0.50)";
			w = "((40 + 80) + 15) * (pixelW * pixelGrid * 0.50)";
			h = "60 * (pixelH * pixelGrid * 0.50)";
			class Controls: Controls {
				class Grp1: GVAR(ctrlGrp) {
					idc = GROUP_1;
					class Controls: Controls {
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
							text = "Groups";
						};
					};
				};
				//-------------------------------------------
				class Grp2: EGVAR(supply,ctrlGrp_ListN) {
					idc = GROUP_2;
					x = "(40 + 5) * (pixelW * pixelGrid * 0.50)";
					class Controls: Controls {
						class Edit: Edit {
							idc = EDIT_2;
							tooltip = "Insert valid class from CfgVehicles here";
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
							text = "Classes";
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
	};
};
