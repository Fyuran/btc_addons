class CfgSkeletons {
	class Default {
		isDiscrete = 1;
		skeletonInherit = "";
		skeletonBones[] = {};
	};
	class GVAR(Skeleton_Floor): Default {
		skeletonInherit = "Default";
		skeletonBones[] = {
			"Plane", "",
		};
	};
	class GVAR(Skeleton_Wall): Default {
		skeletonInherit = "Default";
		skeletonBones[] = {
			"Wall", ""
		};
	};
	
};

class CfgModels {

	class Default {
		sectionsInherit = "";
		sections[] = {};
		skeletonName = "";
	};

	class GVAR(Floor_2x2): Default {
		skeletonName = QGVAR(Skeleton_Floor);
		sections[] = {
			"Plane"
		};
	};
	class GVAR(Floor_2x4): GVAR(Floor_2x2) {};
	class GVAR(Floor_4x4): GVAR(Floor_2x2) {};
	class GVAR(Floor_6x6): GVAR(Floor_2x2) {};

	class GVAR(Floor_2x2_45): GVAR(Floor_2x2) {};
	class GVAR(Floor_2x4_45): GVAR(Floor_2x2) {};
	class GVAR(Floor_4x2_45): GVAR(Floor_2x2) {};
	class GVAR(Floor_4x4_45): GVAR(Floor_2x2) {};
	class GVAR(Floor_4x8_45): GVAR(Floor_2x2) {};

	class GVAR(Wall_4x1): Default {
		skeletonName = QGVAR(Skeleton_Wall);
		sections[] = {
			"Wall"
		};
	};
    class GVAR(Wall_4x2): GVAR(Wall_4x1) {};
    class GVAR(Wall_6x1): GVAR(Wall_4x1) {};
    class GVAR(Wall_6x2): GVAR(Wall_4x1) {};
};
