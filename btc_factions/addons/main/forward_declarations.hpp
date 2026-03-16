class All;
class AllVehicles: All {
	class NewTurret;
	class CargoTurret: NewTurret {};
};
class Land: AllVehicles {};
class LandVehicle: Land {
	class CommanderOptics: NewTurret {};
};

class Car: LandVehicle {};
class Car_F: Car {
	class NewTurret: NewTurret {};
	class Turrets {
		class MainTurret: NewTurret {};
	};
};
class MRAP_02_base_F: Car_F {};

class Tank: LandVehicle {};
class Tank_F: Tank {
	class Turrets {
		class MainTurret: NewTurret {
			class Turrets {
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};

class O_Soldier_AAR_F;
class O_Soldier_F;
class O_Soldier_LAT_F;
class O_Soldier_SL_F;
class O_Soldier_TL_F;
class O_crew_F;
class O_helipilot_F;
class O_soldier_M_F;

class rhs_a3t72tank_base: Tank_F {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderOptics: CommanderOptics {};
				class CommanderMG: CommanderOptics {};
			};
		};
	};
};
class rhs_tank_base: Tank_F {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderOptics: CommanderOptics {};
				class CommanderMG: CommanderOptics {};
			};
		};
	};
};
class rhs_t80b: rhs_tank_base {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
	};
};

class RHS_A10;
class RHS_C130J;
class RHS_C130J_Cargo;
class RHS_Ka52_vvs;
class RHS_M119_D;
class RHS_Mi24V_vdv;
class RHS_Mi8MTV3_vdv;
class RHS_Mi8T_vdv;
class RHS_Mi8mt_vdv;
class RHS_Stinger_AA_pod_D;
class RHS_Su25SM_vvs;
class RHS_T50_vvs_054;
class RHS_TOW_TriPod_D;
class RHS_TU95MS_vvs_chelyabinsk;
class RHS_Ural_Ammo_VDV_01;
class RHS_Ural_Fuel_VDV_01;
class RHS_Ural_Repair_VDV_01;
class RHS_Ural_VDV_01;
class RHS_Ural_Zu23_VDV_01;
class RHS_ZU23_MSV;
class UK3CB_ARD_O_GAZ_Vodnik;
class UK3CB_ARD_O_GAZ_Vodnik_PKT;
class UK3CB_CSAT_S_O_BMP1;
class UK3CB_CSAT_S_O_BMP2;
class UK3CB_CSAT_S_O_BRDM2;
class UK3CB_CSAT_S_O_BRDM2_ATGM;
class UK3CB_CSAT_S_O_BRDM2_HQ;
class UK3CB_CSAT_S_O_BTR60;
class UK3CB_CSAT_S_O_BTR80;
class UK3CB_CSAT_S_O_BTR80a;
class UK3CB_CSAT_S_O_GAZ_Vodnik;
class UK3CB_CSAT_S_O_GAZ_Vodnik_PKT;
class UK3CB_CSAT_S_O_Gaz66_Radio;
class UK3CB_CSAT_S_O_Kajman;
class UK3CB_CSAT_S_O_Marid_Unarmed;
class UK3CB_CSAT_S_O_Mi8;
class UK3CB_CSAT_S_O_Mi8AMT;
class UK3CB_CSAT_S_O_Mi8AMTSh;
class UK3CB_CSAT_S_O_Mi_24G;
class UK3CB_CSAT_S_O_PKM_nest;
class UK3CB_CSAT_S_O_RBS70;
class UK3CB_CSAT_S_O_Radar_System;
class UK3CB_CSAT_S_O_SAMS_System;

class rhs_tigr_base: MRAP_02_base_F {
	class Turrets: Turrets {};
};
class rhs_tigr_vdv: rhs_tigr_base {};
class rhs_tigr_sts_vdv: rhs_tigr_vdv {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class AGS_Turret: MainTurret {};
	};
};
class rhs_tigr_sts_3camo_vdv: rhs_tigr_sts_vdv {
	class Turrets: Turrets {
		class AGS_Turret: MainTurret {};
		class MainTurret: MainTurret {};
	};
};

class rhs_t72ba_tv: rhs_a3t72tank_base {};
class UK3CB_T72BA: rhs_t72ba_tv {};
class UK3CB_O_T72BA_CSAT_S: UK3CB_T72BA {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderMG: CommanderMG {};
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};
class UK3CB_CSAT_S_O_T72BA: UK3CB_O_T72BA_CSAT_S {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderMG: CommanderMG {};
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};
class rhs_t80: rhs_t80b {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};
class UK3CB_T80: rhs_t80 {};
class UK3CB_O_T80_CSAT_S: UK3CB_T80 {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};
class UK3CB_CSAT_S_O_T80: UK3CB_O_T80_CSAT_S {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};
class UK3CB_CSAT_S_O_Tigr_FFV;
class UK3CB_TIGR_STS: rhs_tigr_sts_3camo_vdv {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class AGS_Turret: AGS_Turret {};
	};
};
class UK3CB_O_TIGR_STS_CSAT_S: UK3CB_TIGR_STS {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class AGS_Turret: AGS_Turret {};
	};
};
class UK3CB_CSAT_S_O_Tigr_STS: UK3CB_O_TIGR_STS_CSAT_S {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class AGS_Turret: AGS_Turret {};
	};
};

class UK3CB_CSAT_S_O_UAZ_Closed;
class UK3CB_CSAT_S_O_Ural;
class UK3CB_CSAT_S_O_Ural_Ammo;
class UK3CB_CSAT_S_O_Ural_Fuel;
class UK3CB_CSAT_S_O_Ural_Repair;

class Truck_F: Car_F {};
class RHS_Ural_BaseTurret: Truck_F {
	class Turrets {
		class MainTurret: NewTurret {};
	};
};
class RHS_Ural_Zu23_Base: RHS_Ural_BaseTurret {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class CargoTurret_01: CargoTurret {};
		class CargoTurret_02: CargoTurret {};
		class CargoTurret_03: CargoTurret {};
	};
};
class UK3CB_Ural_Zu23_Base: RHS_Ural_Zu23_Base {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class CargoTurret_01: CargoTurret_01 {};
		class CargoTurret_02: CargoTurret_02 {};
		class CargoTurret_03: CargoTurret_03 {};
	};
};
class UK3CB_O_Ural_ZU23_CSAT_S: UK3CB_Ural_Zu23_Base {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class CargoTurret_01: CargoTurret_01 {};
		class CargoTurret_02: CargoTurret_02 {};
		class CargoTurret_03: CargoTurret_03 {};
	};
};
class UK3CB_CSAT_S_O_Ural_Zu23: UK3CB_O_Ural_ZU23_CSAT_S {
	class Turrets: Turrets {
		class MainTurret: MainTurret {};
		class CargoTurret_01: CargoTurret_01 {};
		class CargoTurret_02: CargoTurret_02 {};
		class CargoTurret_03: CargoTurret_03 {};
	};
};

class UK3CB_CW_SOV_O_EARLY_Antonov_AN2;
class UK3CB_ION_B_Desert_Bell412_Utility;
class UK3CB_ION_B_Desert_MELB_AH6M;
class UK3CB_ION_B_Desert_MELB_MH6M;
class UK3CB_ION_B_Desert_T810_Closed;
class UK3CB_ION_B_Desert_UH1H_GUNSHIP;
class UK3CB_ION_B_Urban_Cessna_T41_Armed_M134;
class UK3CB_ION_B_Urban_M240_High;
class UK3CB_ION_B_Urban_M240_Low;
class UK3CB_ION_B_Urban_M240_nest;
class UK3CB_ION_B_Urban_M252;
class UK3CB_ION_B_Urban_M2_MiniTripod;
class UK3CB_ION_B_Urban_M2_TriPod;
class UK3CB_ION_O_Desert_Dingo;
class UK3CB_ION_O_Desert_LSV_02;
class UK3CB_ION_O_Desert_LSV_02_Armed;
class UK3CB_ION_O_Desert_M113_M2;
class UK3CB_ION_O_Desert_MaxxPro_M2;
class UK3CB_ION_O_Desert_Offroad;
class UK3CB_ION_O_Desert_Offroad_Covered;
class UK3CB_ION_O_Desert_T810_Reammo;
class UK3CB_ION_O_Desert_T810_Recovery;
class UK3CB_ION_O_Desert_T810_Refuel;
class UK3CB_ION_O_Desert_T810_Repair;
class UK3CB_O_Static_PKM_High_MSV;
class rhs_2b14_82mm_msv;
class rhs_D30_at_msv;
class rhs_Igla_AA_pod_msv;
class rhs_Kornet_9M133_2_msv;
class rhs_Metis_9k115_2_msv;
class rhs_bmp1_vdv;
class rhs_bmp2d_vdv;
class rhs_btr60_vdv;
class rhs_btr80_vdv;
class rhs_btr80a_vdv;
class rhs_gaz66_r142_vdv;
class rhs_mig29sm_vvs;
class rhs_msv_emr_officer;

class rhs_t72bc_tv: rhs_a3t72tank_base {};
class rhs_t80bk: rhs_t80b {
	class Turrets: Turrets {
		class MainTurret: MainTurret {
			class Turrets: Turrets {
				class CommanderMG: CommanderMG {};
				class CommanderOptics: CommanderOptics {};
			};
		};
	};
};

class rhs_tigr_3camo_vdv;
class rhs_uaz_open_vdv;
class rhsgref_BRDM2_ATGM_vdv;
class rhsgref_BRDM2_HQ_vdv;
class rhsgref_BRDM2_vdv;
class rhsgref_ins_arifleman_rpk;
class rhsgref_ins_machinegunner;
class rhsusf_f22;
