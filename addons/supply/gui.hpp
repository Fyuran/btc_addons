class GVAR(ctrlGrp): ctrlControlsGroupNoScrollbars {
	w = "40 * (pixelW * pixelGrid * 0.50)";
	h = "60 * (pixelH * pixelGrid * 0.50)";
	class Controls {
		class Title: ctrlStaticTitle {
			style = 2;
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Edit: ctrlEdit {
			y = "5 * (pixelH * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
			tooltip = "Add Object classes";
		};
		class Add: ctrlButton {
			text = "Add";
			y = "10 * (pixelH * pixelGrid * 0.50)";
			w = "20 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Remove: ctrlButton {
			text = "Remove";
			x = "20 * (pixelW * pixelGrid * 0.50)";
			y = "10 * (pixelH * pixelGrid * 0.50)";
			w = "20 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class List: ctrlListBox {
			y = "15 * (pixelH * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "40 * (pixelH * pixelGrid * 0.50)";
			style = "0x02 + 0x10";
		};
	};
};
class GVAR(ctrlGrp_ListN): ctrlControlsGroupNoScrollbars {
	w = "80 * (pixelW * pixelGrid * 0.50)";
	h = "60 * (pixelH * pixelGrid * 0.50)";
	class Controls {
		class Title: ctrlStaticTitle {
			style = 2;
			w = "80 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Edit: ctrlEdit {
			y = "5 * (pixelH * pixelGrid * 0.50)";
			w = "80 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
			tooltip = "Add Inventory classes";
		};
		class Add: ctrlButton {
			text = "Add";
			y = "10 * (pixelH * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class Remove: ctrlButton {
			text = "Remove";
			x = "40 * (pixelW * pixelGrid * 0.50)";
			y = "10 * (pixelH * pixelGrid * 0.50)";
			w = "40 * (pixelW * pixelGrid * 0.50)";
			h = "5 * (pixelH * pixelGrid * 0.50)";
		};
		class ArrowLeft: ctrlButton {
			text = "-";
		};
		class ArrowRight: ctrlButton {
			text = "+";
		};
		class List: ctrlListNBox {
			drawSideArrows = 1;
			columns[] = {"5 * (pixelW * pixelGrid * 0.50)", "75 * (pixelW * pixelGrid * 1)"};
			y = "15 * (pixelH * pixelGrid * 0.50)";
			w = "80 * (pixelW * pixelGrid * 0.50)";
			h = "40 * (pixelH * pixelGrid * 0.50)";
		};
		class List_Background1: ctrlStaticBackground {
			colorBackground[] = {0, 0, 0, 0.2};
			y = "15 * (pixelH * pixelGrid * 0.50)";
			w = "70 * (pixelW * pixelGrid * 0.50)";
			h = "40 * (pixelH * pixelGrid * 0.50)";
		};
		class List_Background2: ctrlStaticBackground {
			colorBackground[] = {0, 0, 0, 0.5};
			x = "70 * (pixelW * pixelGrid * 0.50)";
			y = "15 * (pixelH * pixelGrid * 0.50)";
			w = "10 * (pixelW * pixelGrid * 0.50)";
			h = "40 * (pixelH * pixelGrid * 0.50)";
		};
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
		class GVAR(class): Combo {
			onLoad = "params[""_grp""]; _combo = _grp controlsGroupCtrl 66650; [_combo] call btc_supply_fnc_combo_init;";
			attributeLoad = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66650; [_combo, _value] call btc_supply_fnc_combo_load;";
			attributeSave = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66650; [_combo] call btc_supply_fnc_combo_save;";
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = COMBO;
				};
			};
		};
		class GVAR(enableDamage): Checkbox {
			onLoad = "params[""_grp""]; _combo = _grp controlsGroupCtrl 66651; [_combo] call btc_supply_fnc_checkbox_init;";
			attributeLoad = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66651; [_combo, _value] call btc_supply_fnc_checkbox_load;";
			attributeSave = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66651; [_combo] call btc_supply_fnc_checkbox_save;";
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = CHECKBOX;
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
					onButtonClick = "[] call btc_supply_fnc_presets_init;";
					text = "Presets";
					colorBackground[] = {0.13, 0.47, 0.30, 1};
					w = "40 * (pixelW * pixelGrid * 0.50)";
					h = "5 * (pixelH * pixelGrid * 0.50)";
				};
			};
		};
		class GVAR(list): Title {
			onLoad = "params[""_grp""]; [_grp] call btc_supply_fnc_list_init;";
			attributeLoad = "params[""_grp""]; [_grp, _value] call btc_supply_fnc_list_load;";
			attributeSave = "[] call btc_supply_fnc_list_save;";
			x = "5 * (pixelW * pixelGrid * 0.50)";
			w = "((40 + 80) + 15) * (pixelW * pixelGrid * 0.50)";
			h = "60 * (pixelH * pixelGrid * 0.50)";
			class Controls: Controls {
				class Grp1: GVAR(ctrlGrp) {
					idc = GROUP_1;
					class Controls: Controls {
						class Edit: Edit {
							idc = EDIT_1;
							tooltip = "Insert valid class from CfgVehicles here";
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
							text = "Objects";
						};
					};
				};
				//-------------------------------------------
				class Grp2: GVAR(ctrlGrp_ListN) {
					idc = GROUP_2;
					x = "(40 + 5) * (pixelW * pixelGrid * 0.50)";
					class Controls: Controls {
						class Edit: Edit {
							idc = EDIT_2;
							tooltip = "Insert valid class from CfgWeapons or CfgMagazines here";
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
							text = "Supplies";
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
