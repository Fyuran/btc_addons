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
PREP_FOLDER(list,grp1Add);
PREP_FOLDER(list,grp1Remove);
PREP_FOLDER(list,grp1LbSelChanged);
PREP_FOLDER(list,grp2Add);
PREP_FOLDER(list,grp2Remove);
PREP_FOLDER(list,grp2OnAdjust);


// enableDamage
PREP_FOLDER(enableDamage,onLoad);

// curator
PREP_FOLDER(curator,init);
PREP_FOLDER(curator,okCode);

// presets
PREP_FOLDER(presets,applyData);
PREP_FOLDER(presets,gatherData);
PREP_FOLDER(presets,open);
