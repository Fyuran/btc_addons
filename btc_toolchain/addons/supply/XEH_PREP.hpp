#include "script_component.hpp"

// drop
PREP(drop);
PREP(dropCrate);
PREP(fillInventory);
PREP(spawnVehicle);
PREP(debug);

// list
PREP_FOLDER(list,attributeLoad);
PREP_FOLDER(list,attributeSave);
PREP_FOLDER(list,onLoad);
PREP_FOLDER(list,grp1_add);
PREP_FOLDER(list,grp1_remove);
PREP_FOLDER(list,grp1_LBSelChanged);
PREP_FOLDER(list,grp2_add);
PREP_FOLDER(list,grp2_remove);
PREP_FOLDER(list,grp2_onAdjust);

// combo
PREP_FOLDER(combo,onLoad);
PREP_FOLDER(combo,attributeLoad);
PREP_FOLDER(combo,attributeSave);

// enableDamage
PREP_FOLDER(enableDamage,onLoad);

// curator
PREP_FOLDER(curator,init);
PREP_FOLDER(curator,OKCode);

// presets
PREP_FOLDER(presets,applyData);
PREP_FOLDER(presets,gatherData);
PREP_FOLDER(presets,open);
