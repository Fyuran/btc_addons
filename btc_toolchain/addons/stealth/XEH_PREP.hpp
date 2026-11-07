#include "script_component.hpp"

// core
PREP_FOLDER(core,init);
PREP_FOLDER(core,ehInit);
PREP_FOLDER(core,manualTransition);
PREP_FOLDER(core,debug);

// cover
PREP_FOLDER(cover,debugCover);
PREP_FOLDER(cover,findCover);
PREP_FOLDER(cover,getBoundingBoxFacesModel);
PREP_FOLDER(cover,getCentroid);
PREP_FOLDER(cover,getCoverPositionsAgl);
PREP_FOLDER(cover,getFaceMidpointModel);
PREP_FOLDER(cover,isPositionHiddenAsl);
PREP_FOLDER(cover,nearestSortedObjects);

// fsm
PREP_FOLDER(fsm,alert);
PREP_FOLDER(fsm,cover);
PREP_FOLDER(fsm,init);
PREP_FOLDER(fsm,investigate);
PREP_FOLDER(fsm,investigateBody);
PREP_FOLDER(fsm,patrol);
PREP_FOLDER(fsm,reinf);

// reinforcements
PREP_FOLDER(reinforcements,callReinforcements);
PREP_FOLDER(reinforcements,callRemoveReinforcements);

// threat
PREP_FOLDER(threat,addThreat);
PREP_FOLDER(threat,setThreat);
PREP_FOLDER(threat,dispatchBody);
PREP_FOLDER(threat,getAllSideCorpses);
PREP_FOLDER(threat,setLastKnownPosition);
PREP_FOLDER(threat,unitDetectEntities);

// waypoints
PREP_FOLDER(waypoints,clearWaypoints);
PREP_FOLDER(waypoints,detachGroup);
PREP_FOLDER(waypoints,execNearbyGrps);
PREP_FOLDER(waypoints,getWaypoints);
PREP_FOLDER(waypoints,setWaypoints);
