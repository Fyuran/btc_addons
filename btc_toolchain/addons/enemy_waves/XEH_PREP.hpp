#include "script_component.hpp"

//Behavior
PREP_FOLDER(behavior,attributeLoad);

//Seek end Checkbox
PREP_FOLDER(seekCheckbox,onLoad);

//Side Combo
PREP_FOLDER(sideCombo,onLoad);
PREP_FOLDER(sideCombo,attributeLoad);

//Timeout
PREP_FOLDER(timeout,onLoad);
PREP_FOLDER(timeout,attributeLoad);

//List
PREP_FOLDER(list,attributeLoad);
PREP_FOLDER(list,attributeSave);
PREP_FOLDER(list,onLoad);
PREP_FOLDER(list,grp1Add);
PREP_FOLDER(list,grp1Remove);
PREP_FOLDER(list,grp1LbSelChanged);
PREP_FOLDER(list,grp2Add);
PREP_FOLDER(list,grp2Remove);
PREP_FOLDER(list,grp2OnAdjust);

//Curator
PREP_FOLDER(curator,init);
PREP_FOLDER(curator,okCode);

//Presets
PREP_FOLDER(presets,applyData);
PREP_FOLDER(presets,gatherData);
PREP_FOLDER(presets,open);

//Spawn
PREP_FOLDER(spawn,addEH);
PREP_FOLDER(spawn,begin);

//Type
PREP_FOLDER(type,attributeLoad);
PREP_FOLDER(type,attributeSave);
PREP_FOLDER(type,onLoad);
PREP_FOLDER(type,onTreeSelChanged);

//Waypoints module
PREP_FOLDER(wp,add);
PREP_FOLDER(wp,getNextModule);
PREP_FOLDER(wp,moduleInit);
PREP_FOLDER(wp,toPlayer);
PREP_FOLDER(wp,processAttribute);

//Debug
PREP(debug);
