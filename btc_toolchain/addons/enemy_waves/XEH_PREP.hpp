#include "script_component.hpp"

//Seek end Checkbox
PREP_FOLDER(seek_checkbox,init);

//Side Combo
PREP_FOLDER(side_combo,init);
PREP_FOLDER(side_combo,attributeLoad);

//Timeout
PREP_FOLDER(timeout,init);
PREP_FOLDER(timeout,attributeLoad);

//List
PREP_FOLDER(list,attributeLoad);
PREP_FOLDER(list,attributeSave);
PREP_FOLDER(list,init);
PREP_FOLDER(list,grp1_add);
PREP_FOLDER(list,grp1_remove);
PREP_FOLDER(list,grp1_lbSelChanged);
PREP_FOLDER(list,grp2_add);
PREP_FOLDER(list,grp2_remove);
PREP_FOLDER(list,grp2_onAdjust);

//Curator
PREP_FOLDER(curator,init);
PREP_FOLDER(curator,OKCode);

//Presets
PREP_FOLDER(presets,applyData);
PREP_FOLDER(presets,gatherData);
PREP_FOLDER(presets,open);

//Spawn
PREP_FOLDER(spawn,addEH);
PREP_FOLDER(spawn,begin);

//Waypoints module
PREP_FOLDER(wp,add);
PREP_FOLDER(wp,getNextModule);
PREP_FOLDER(wp,moduleInit);
PREP_FOLDER(wp,toPlayer);
PREP_FOLDER(wp,processAttribute);

//Waypoints Type GUI
PREP_FOLDER(wp,gui_init);
PREP_FOLDER(wp,gui_load);
PREP_FOLDER(wp,gui_save);
