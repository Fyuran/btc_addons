#include "script_component.hpp"

PREP(debug);
PREP(init);

// class
PREP_FOLDER(class,hasWeapons);
PREP_FOLDER(class,onLBSelChanged);

// curator
PREP_FOLDER(curator,init);
PREP_FOLDER(curator,okCode);

// list
PREP_FOLDER(list,attributeLoad);
PREP_FOLDER(list,attributeSave);
PREP_FOLDER(list,initVehicleData);
PREP_FOLDER(list,onLoad);

// presets
PREP_FOLDER(presets,applyData);
PREP_FOLDER(presets,gatherData);
PREP_FOLDER(presets,open);

// vehicle
PREP_FOLDER(vehicle,dive);
PREP_FOLDER(vehicle,fire);
PREP_FOLDER(vehicle,spawn);
PREP_FOLDER(vehicle,remoteControl);
