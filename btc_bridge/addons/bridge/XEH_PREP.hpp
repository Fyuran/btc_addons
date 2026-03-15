#include "script_component.hpp"
//Global
PREP(initPost);

//Server
PREP_S(addEH);
PREP_S(removeEH);
PREP_S(replace);

//Owner
PREP_O(addAction);
PREP_O(eraseJIP);
PREP_O(pictureRotation);
PREP_O(setDIKColors);
PREP_O(init_gui);
PREP_O(init);
PREP_O(keyDown);
PREP_O(setCameraPos);
PREP_O(setHelperPos);

//Client
PREP_C(addNext);
PREP_C(animation_in);
PREP_C(animation_out);
PREP_C(removeAll);
PREP_C(removeLast);
PREP_C(setHeight);
PREP_C(setIsAnimating);
