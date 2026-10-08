#include "script_component.hpp"

// core
PREP_FOLDER(core,init);
PREP_FOLDER(core,EH_init);
PREP_FOLDER(core,manualTransition);
PREP_FOLDER(core,debug);

// cover
PREP_FOLDER(cover,debugCover);
PREP_FOLDER(cover,findCover);
PREP_FOLDER(cover,getBoundingBoxFaces_Model);
PREP_FOLDER(cover,getCentroid);
PREP_FOLDER(cover,getCoverPositions_AGL);
PREP_FOLDER(cover,getFaceMidpoint_Model);
PREP_FOLDER(cover,isPositionHidden_ASL);
PREP_FOLDER(cover,nearestSortedObjects);

// fsm
PREP_FOLDER(fsm,FSM_alert);
PREP_FOLDER(fsm,FSM_cover);
PREP_FOLDER(fsm,FSM_init);
PREP_FOLDER(fsm,FSM_investigate);
PREP_FOLDER(fsm,FSM_investigate_body);
PREP_FOLDER(fsm,FSM_patrol);
PREP_FOLDER(fsm,FSM_reinf);

// reinforcements
PREP_FOLDER(reinforcements,call_reinforcements);
PREP_FOLDER(reinforcements,call_removeReinforcements);

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
