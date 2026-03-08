class CfgSkeletons {
	class Default {
		isDiscrete = 1;
		skeletonInherit = "";
		skeletonBones[] = {};
	};
	class Skeleton_Floor: Default {
		skeletonInherit = "Default";
		skeletonBones[] = {
			"Plane", "",
		};
	};
	class Skeleton_Wall: Default {
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

	class Floor_2x2: Default {
		skeletonName = QUOTE(Skeleton_Floor);
		sections[] = {
			"Plane"
		};
	};
	class Floor_2x4: Floor_2x2 {};
	class Floor_4x4: Floor_2x2 {};
	class Floor_6x6: Floor_2x2 {};

	class Floor_2x2_45: Floor_2x2 {};
	class Floor_2x4_45: Floor_2x2 {};
	class Floor_4x2_45: Floor_2x2 {};
	class Floor_4x4_45: Floor_2x2 {};
	class Floor_4x8_45: Floor_2x2 {};

	class Wall_4x1: Default {
		skeletonName = QUOTE(Skeleton_Wall);
		sections[] = {
			"Wall"
		};
	};
    class Wall_4x2: Wall_4x1 {};
    class Wall_6x1: Wall_4x1 {};
    class Wall_6x2: Wall_4x1 {};
};
