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
		class GVAR(side): Combo {
			onLoad = "params[""_grp""]; _combo = _grp controlsGroupCtrl 66650; [_combo] call btc_enemy_waves_fnc_combo_init;";
			attributeLoad = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66650; [_combo, _value] call btc_enemy_waves_fnc_combo_load;";
			attributeSave = "params[""_grp""];  _combo = _grp controlsGroupCtrl 66650; [_combo] call btc_enemy_waves_fnc_combo_save;";
			class Controls: Controls {
				class Title: Title {
					idc = -1;
				};
				class Value: Value {
					idc = COMBO;
				};
			};
		};
	};
};
