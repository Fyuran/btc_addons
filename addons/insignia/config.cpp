#include "script_component.hpp"

class CfgPatches {
	class ADDON {
		name = "=BTC= Toolchain Insignia";
		author = MAIN_AUTHOR;
        authors[] = {AUTHORS};
		units[] = {};
		url = "https://www.blacktemplars.it/";
		requiredVersion = REQUIRED_VERSION;
		weapons[] = {};
		requiredAddons[] = {"btc_toolchain_main"};
		VERSION_CONFIG;
	};
};

class CfgUnitInsignia {
	class GVAR(1) {
		displayName = "Tiny Bunny - Alice the Fox";
		author = "Fyuran";
		texture = QPATHTOF(data\alissa_patch.paa);
		material = "\A3\Ui_f\data\GUI\Cfg\UnitInsignia\default_insignia.rvmat";
		textureVehicle = "";
	};

	class GVAR(medic_1) : GVAR(1) {
		displayName = "Medic - Patch 1";
		texture = QPATHTOF(data\medic_patch_1.paa);
	};

	class GVAR(medic_2) : GVAR(1) {
		displayName = "Medic - Patch 2";
		texture = QPATHTOF(data\medic_patch_2.paa);
	};
	
	class GVAR(medic_3) : GVAR(1) {
		displayName = "Medic - Patch 3";
		texture = QPATHTOF(data\medic_patch_3.paa);
	};
	
	class GVAR(medic_4) : GVAR(1) {
		displayName = "Medic - Patch 4";
		texture = QPATHTOF(data\medic_patch_4.paa);
	};
	
	class GVAR(medic_5) : GVAR(1) {
		displayName = "Medic - Patch 5";
		texture = QPATHTOF(data\medic_patch_5.paa);
	};

	class GVAR(medic_6) : GVAR(1) {
		displayName = "Medic - Patch 6";
		texture = QPATHTOF(data\medic_patch_6.paa);
	};

	class GVAR(diamonddogs_1) : GVAR(1) {
		displayName = "Diamond Dogs - Patch 1";
		texture = QPATHTOF(data\diamonddogs_patch_1.paa);
	};

	class GVAR(xof_1) : GVAR(1) {
		displayName = "XOF - Patch 1";
		texture = QPATHTOF(data\xof_patch_1.paa);
	};

	class GVAR(xof_2) : GVAR(1) {
		displayName = "XOF - Patch 2";
		texture = QPATHTOF(data\xof_patch_2.paa);
	};

	class GVAR(foxhound_1) : GVAR(1) {
		displayName = "Fox-Hound - Patch 1";
		texture = QPATHTOF(data\foxhound_patch_1.paa);
	};

	class GVAR(outerheaven_1) : GVAR(1) {
		displayName = "Outer Heaven - Patch 1";
		texture = QPATHTOF(data\outer_heaven_patch_1.paa);
	};

	class GVAR(blackmesa_1) : GVAR(1) {
		displayName = "Black Mesa - Patch 1";
		texture = QPATHTOF(data\blackmesa_patch_1.paa);
	};

	class GVAR(beratnasgas_1) : GVAR(1) {
		displayName = "Beratnas Gas - Patch 1";
		texture = QPATHTOF(data\beratnasgas_patch_1.paa);
	};

	class GVAR(mcrn_1) : GVAR(1) {
		displayName = "MCRN - Patch 1";
		texture = QPATHTOF(data\mcrn_patch_1.paa);
	};

	class GVAR(mcrn_2) : GVAR(1) {
		displayName = "MCRN - Patch 2";
		texture = QPATHTOF(data\mcrn_patch_2.paa);
	};

	class GVAR(starhelix_1) : GVAR(1) {
		displayName = "Star Helix - Patch 1";
		texture = QPATHTOF(data\starhelix_patch_1.paa);
	};

	class GVAR(starhelix_2) : GVAR(1) {
		displayName = "Star Helix - Patch 2";
		texture = QPATHTOF(data\starhelix_patch_2.paa);
	};

	class GVAR(otago_1) : GVAR(1) {
		displayName = "Otago - Patch 1";
		texture = QPATHTOF(data\otago_patch_1.paa);
	};

	class GVAR(sulaco_1) : GVAR(1) {
		displayName = "Sulaco - Patch 1";
		texture = QPATHTOF(data\sulaco_patch_1.paa);
	};

	class GVAR(usmc_1) : GVAR(1) {
		displayName = "USMC - Patch 1";
		texture = QPATHTOF(data\usmc_patch_1.paa);
	};

	class GVAR(unreal_1) : GVAR(1) {
		displayName = "Unreal - Patch 1";
		texture = QPATHTOF(data\unreal_patch_1.paa);
	};

	class GVAR(stars_1) : GVAR(1) {
		displayName = "S.T.A.R.S. - Patch 1";
		texture = QPATHTOF(data\stars_patch_1.paa);
	};
};
