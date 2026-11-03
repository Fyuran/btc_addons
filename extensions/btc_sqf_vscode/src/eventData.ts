export interface SqfEventInfo {
    name: string;
    description: string;
    params: string;
}

export const OBJECT_EVENTS: SqfEventInfo[] = [
    {
        name: "AnimChanged",
        description: "Triggered when the unit's animation state changes.",
        params: 'params ["_unit", "_anim"];'
    },
    {
        name: "AnimDone",
        description: "Triggered when the unit's animation has finished playing.",
        params: 'params ["_unit", "_anim"];'
    },
    {
        name: "AnimStateChanged",
        description: "Triggered when the unit's animation state changes.",
        params: 'params ["_unit", "_anim"];'
    },
    {
        name: "CargoLoaded",
        description: "Triggered when vehicle cargo is loaded into a vehicle.",
        params: 'params ["_vehicle", "_cargo"];'
    },
    {
        name: "CargoUnloaded",
        description: "Triggered when vehicle cargo is unloaded from a vehicle.",
        params: 'params ["_vehicle", "_cargo"];'
    },
    {
        name: "ContainerClosed",
        description: "Triggered when a container (backpack, vest, uniform, vehicle cargo, weapon holder) inventory is closed.",
        params: 'params ["_container", "_unit"];'
    },
    {
        name: "ContainerOpened",
        description: "Triggered when a container inventory is opened.",
        params: 'params ["_container", "_unit"];'
    },
    {
        name: "ControlsShifted",
        description: "Triggered when vehicle control shifts to another unit.",
        params: 'params ["_vehicle", "_newController", "_oldController"];'
    },
    {
        name: "Dammaged",
        description: "Triggered when the unit or vehicle takes damage (dammaged is an older variant of HandleDamage).",
        params: 'params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];'
    },
    {
        name: "Deleted",
        description: "Triggered when an entity is deleted from the game world.",
        params: 'params ["_entity"];'
    },
    {
        name: "Engine",
        description: "Triggered when the vehicle engine turns on or off.",
        params: 'params ["_vehicle", "_engineState"];'
    },
    {
        name: "EpeContact",
        description: "Triggered continuously when PhysX collision contact persists between two objects.",
        params: 'params ["_object1", "_object2", "_selection1", "_selection2", "_force"];'
    },
    {
        name: "EpeContactEnd",
        description: "Triggered when PhysX collision contact between two objects ends.",
        params: 'params ["_object1", "_object2", "_selection1", "_selection2", "_force"];'
    },
    {
        name: "EpeContactStart",
        description: "Triggered when PhysX collision contact between two objects begins.",
        params: 'params ["_object1", "_object2", "_selection1", "_selection2", "_force"];'
    },
    {
        name: "Explosion",
        description: "Triggered when an explosion damages the vehicle or unit.",
        params: 'params ["_vehicle", "_damage", "_owner"];'
    },
    {
        name: "Fired",
        description: "Triggered when a weapon is fired by the unit or vehicle.",
        params: 'params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];'
    },
    {
        name: "FiredMan",
        description: "Triggered when an infantry soldier fires a weapon (works on soldiers even inside vehicles).",
        params: 'params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];'
    },
    {
        name: "FiredNear",
        description: "Triggered when a weapon is fired within 69 meters of the unit.",
        params: 'params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];'
    },
    {
        name: "Fuel",
        description: "Triggered when vehicle fuel runs out or fuel state changes.",
        params: 'params ["_vehicle", "_fuelState"];'
    },
    {
        name: "Gear",
        description: "Triggered when landing gear state changes (deployed or retracted).",
        params: 'params ["_vehicle", "_gearState"];'
    },
    {
        name: "GetIn",
        description: "Triggered on a vehicle when a unit enters it.",
        params: 'params ["_vehicle", "_role", "_unit", "_turret"];'
    },
    {
        name: "GetInMan",
        description: "Triggered on a soldier when entering a vehicle.",
        params: 'params ["_unit", "_role", "_vehicle", "_turret"];'
    },
    {
        name: "GetOut",
        description: "Triggered on a vehicle when a unit exits it.",
        params: 'params ["_vehicle", "_role", "_unit", "_turret"];'
    },
    {
        name: "GetOutMan",
        description: "Triggered on a soldier when exiting a vehicle.",
        params: 'params ["_unit", "_role", "_vehicle", "_turret"];'
    },
    {
        name: "HandleDamage",
        description: "Triggered when the unit takes damage. Return damage to apply or custom value.",
        params: 'params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];'
    },
    {
        name: "HandleHeal",
        description: "Triggered when the unit is being healed.",
        params: 'params ["_unit", "_healer", "_isMedic"];'
    },
    {
        name: "HandleRating",
        description: "Triggered when the unit rating is altered. Return modified rating to override.",
        params: 'params ["_unit", "_rating"];'
    },
    {
        name: "HandleScore",
        description: "Triggered when score is awarded in multiplayer. Return modified score or true/false.",
        params: 'params ["_unit", "_object", "_score"];'
    },
    {
        name: "Hit",
        description: "Triggered when the unit or vehicle is hit by a projectile or collision.",
        params: 'params ["_unit", "_causedBy", "_damage", "_instigator"];'
    },
    {
        name: "HitPart",
        description: "Triggered when a projectile hits the object. Provides detailed physics and penetration info.",
        params: 'params ["_target", "_shooter", "_bullet", "_position", "_velocity", "_selection", "_ammo", "_direction", "_radius", "_surface", "_direct"];'
    },
    {
        name: "IncomingMissile",
        description: "Triggered when a guided missile is locked on and launched at the vehicle.",
        params: 'params ["_target", "_ammo", "_vehicle", "_instigator"];'
    },
    {
        name: "InventoryClosed",
        description: "Triggered when the unit closes inventory.",
        params: 'params ["_unit", "_container"];'
    },
    {
        name: "InventoryOpened",
        description: "Triggered when the unit opens inventory. Return true to prevent opening.",
        params: 'params ["_unit", "_container", "_secondaryContainer"];'
    },
    {
        name: "Killed",
        description: "Triggered when the unit or vehicle is killed or destroyed.",
        params: 'params ["_unit", "_killer", "_instigator", "_useEffects"];'
    },
    {
        name: "Landing",
        description: "Triggered when AI airplane starts landing sequence.",
        params: 'params ["_plane", "_airportId"];'
    },
    {
        name: "LandingCanceled",
        description: "Triggered when AI airplane cancels landing.",
        params: 'params ["_plane", "_airportId"];'
    },
    {
        name: "LandedTouchDown",
        description: "Triggered when an airplane touches down on the runway.",
        params: 'params ["_plane", "_airportId"];'
    },
    {
        name: "LandedStopped",
        description: "Triggered when an airplane comes to a complete stop after landing.",
        params: 'params ["_plane", "_airportId"];'
    },
    {
        name: "LaserTargetChanged",
        description: "Triggered when laser target locked by vehicle changes.",
        params: 'params ["_vehicle", "_target"];'
    },
    {
        name: "Local",
        description: "Triggered when locality of the object changes between client and server.",
        params: 'params ["_entity", "_isLocal"];'
    },
    {
        name: "Lock",
        description: "Triggered when vehicle lock state changes.",
        params: 'params ["_vehicle", "_locked"];'
    },
    {
        name: "OpticsIn",
        description: "Triggered when switching to optics view in a vehicle.",
        params: 'params ["_vehicle", "_opticsName"];'
    },
    {
        name: "OpticsOut",
        description: "Triggered when switching out of optics view in a vehicle.",
        params: 'params ["_vehicle", "_opticsName"];'
    },
    {
        name: "PathCalculated",
        description: "Triggered when an AI agent calculates a navigation path.",
        params: 'params ["_agent", "_path"];'
    },
    {
        name: "PersonTurretFiredMan",
        description: "Triggered when a unit in a FFV (firing from vehicles) turret fires.",
        params: 'params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];'
    },
    {
        name: "PilotBank",
        description: "Triggered when airplane bank angle changes.",
        params: 'params ["_plane", "_bank"];'
    },
    {
        name: "PilotPitch",
        description: "Triggered when airplane pitch changes.",
        params: 'params ["_plane", "_pitch"];'
    },
    {
        name: "PilotYaw",
        description: "Triggered when airplane yaw changes.",
        params: 'params ["_plane", "_yaw"];'
    },
    {
        name: "PostReset",
        description: "Triggered after weapon assembly or disassembly resets.",
        params: 'params ["_unit"];'
    },
    {
        name: "PreloadFinished",
        description: "Triggered when object resources finished preloading.",
        params: 'params ["_unit"];'
    },
    {
        name: "PreReset",
        description: "Triggered before weapon assembly or disassembly resets.",
        params: 'params ["_unit"];'
    },
    {
        name: "Reloaded",
        description: "Triggered when unit or vehicle finishes reloading weapon.",
        params: 'params ["_unit", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];'
    },
    {
        name: "Respawn",
        description: "Triggered when player unit respawns.",
        params: 'params ["_unit", "_corpse"];'
    },
    {
        name: "RopeAttach",
        description: "Triggered when sling load rope attaches to an object.",
        params: 'params ["_vehicle", "_rope", "_attachedObject"];'
    },
    {
        name: "RopeBreak",
        description: "Triggered when sling load rope breaks.",
        params: 'params ["_vehicle", "_rope", "_attachedObject"];'
    },
    {
        name: "SeatSwitched",
        description: "Triggered on vehicle when units switch seats.",
        params: 'params ["_vehicle", "_unit1", "_unit2"];'
    },
    {
        name: "SeatSwitchedMan",
        description: "Triggered on soldier unit when switching seats in vehicle.",
        params: 'params ["_unit1", "_unit2", "_vehicle"];'
    },
    {
        name: "SoundPlayed",
        description: "Triggered when unit plays a sound or voice cue.",
        params: 'params ["_unit", "_soundCode"];'
    },
    {
        name: "Suppressed",
        description: "Triggered when a bullet passes near a soldier, causing suppression.",
        params: 'params ["_unit", "_distance", "_shooter", "_ammo", "_direction"];'
    },
    {
        name: "Take",
        description: "Triggered when a unit takes an item from a container or ground.",
        params: 'params ["_unit", "_container", "_item"];'
    },
    {
        name: "TaskSetAsCurrent",
        description: "Triggered when a task is set as the current task.",
        params: 'params ["_unit", "_task"];'
    },
    {
        name: "TurretElevation",
        description: "Triggered when vehicle turret elevation changes.",
        params: 'params ["_vehicle", "_turretIndex", "_elevation"];'
    },
    {
        name: "TurretElevationLocal",
        description: "Triggered locally when vehicle turret elevation changes.",
        params: 'params ["_vehicle", "_turretIndex", "_elevation"];'
    },
    {
        name: "TurretOpticsIn",
        description: "Triggered when switching into vehicle turret optics view.",
        params: 'params ["_vehicle", "_turretIndex", "_opticsName"];'
    },
    {
        name: "TurretOpticsOut",
        description: "Triggered when switching out of vehicle turret optics view.",
        params: 'params ["_vehicle", "_turretIndex", "_opticsName"];'
    },
    {
        name: "TurretYaw",
        description: "Triggered when vehicle turret yaw (azimuth) changes.",
        params: 'params ["_vehicle", "_turretIndex", "_yaw"];'
    },
    {
        name: "TurretYawLocal",
        description: "Triggered locally when vehicle turret yaw changes.",
        params: 'params ["_vehicle", "_turretIndex", "_yaw"];'
    },
    {
        name: "VisionModeChanged",
        description: "Triggered when vision mode (normal, NVG, thermal) changes.",
        params: 'params ["_person", "_visionMode", "_tiIndex", "_visionModeArgs"];'
    },
    {
        name: "WeaponAssembled",
        description: "Triggered when a unit assembles a static weapon or UAV.",
        params: 'params ["_unit", "_weapon"];'
    },
    {
        name: "WeaponDeployed",
        description: "Triggered when unit deploys or undeploys bipod/weapon.",
        params: 'params ["_unit", "_isDeployed"];'
    },
    {
        name: "WeaponDisassembled",
        description: "Triggered when a unit disassembles a static weapon or UAV into backpacks.",
        params: 'params ["_unit", "_primaryBag", "_secondaryBag"];'
    },
    {
        name: "WeaponRested",
        description: "Triggered when unit rests weapon on a surface or moves away.",
        params: 'params ["_unit", "_isRested"];'
    }
];

export const UI_EVENTS: SqfEventInfo[] = [
    {
        name: "ButtonClick",
        description: "Triggered when a UI button is clicked.",
        params: 'params ["_control"];'
    },
    {
        name: "ButtonDown",
        description: "Triggered when a UI button is pressed down.",
        params: 'params ["_control"];'
    },
    {
        name: "ButtonUp",
        description: "Triggered when a UI button is released.",
        params: 'params ["_control"];'
    },
    {
        name: "CanDestroy",
        description: "Triggered when display is about to be destroyed. Return true to allow, false to prevent.",
        params: 'params ["_display"];'
    },
    {
        name: "Char",
        description: "Triggered when a character key is pressed in an edit control.",
        params: 'params ["_control", "_charCode"];'
    },
    {
        name: "ChildDestroyed",
        description: "Triggered when a child display of this display is destroyed.",
        params: 'params ["_display", "_childDisplay", "_exitCode"];'
    },
    {
        name: "Destroy",
        description: "Triggered when the display is destroyed.",
        params: 'params ["_display", "_exitCode"];'
    },
    {
        name: "Draw",
        description: "Triggered every frame when the control (e.g. Map, Custom) is redrawn.",
        params: 'params ["_control"];'
    },
    {
        name: "Focus",
        description: "Triggered when the control receives focus.",
        params: 'params ["_control"];'
    },
    {
        name: "GroupSortChanged",
        description: "Triggered when group sort order changes in list controls.",
        params: 'params ["_control", "_groupIndex", "_sortIndex"];'
    },
    {
        name: "HTMLLink",
        description: "Triggered when an HTML link in RscHTML control is clicked.",
        params: 'params ["_control", "_link"];'
    },
    {
        name: "IMEComposition",
        description: "Triggered during IME text composition.",
        params: 'params ["_control", "_compositionString"];'
    },
    {
        name: "IMECompositionEnd",
        description: "Triggered when IME composition finishes.",
        params: 'params ["_control", "_compositionString"];'
    },
    {
        name: "KeyDown",
        description: "Triggered when a keyboard key is pressed down. Return true to consume the keypress.",
        params: 'params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "KeyUp",
        description: "Triggered when a keyboard key is released. Return true to consume the keypress.",
        params: 'params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "KillFocus",
        description: "Triggered when the control loses focus.",
        params: 'params ["_control"];'
    },
    {
        name: "LBDblClick",
        description: "Triggered when an item in ListBox or ComboBox is double-clicked.",
        params: 'params ["_control", "_selectedIndex"];'
    },
    {
        name: "LBDrop",
        description: "Triggered when an item is dragged and dropped onto a ListBox.",
        params: 'params ["_control", "_xPos", "_yPos"];'
    },
    {
        name: "LBListSelChanged",
        description: "Triggered when selection in ListNBox changes.",
        params: 'params ["_control", "_row", "_column"];'
    },
    {
        name: "LBSelChanged",
        description: "Triggered when selection in ListBox, ComboBox, or ToolBox changes.",
        params: 'params ["_control", "_selectedIndex"];'
    },
    {
        name: "Load",
        description: "Triggered when a display finishes loading.",
        params: 'params ["_display"];'
    },
    {
        name: "MouseButtonClick",
        description: "Triggered when mouse button is clicked over the control.",
        params: 'params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "MouseButtonDblClick",
        description: "Triggered when mouse button is double-clicked over the control.",
        params: 'params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "MouseButtonDown",
        description: "Triggered when mouse button is pressed down. Return true to consume the event.",
        params: 'params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "MouseButtonUp",
        description: "Triggered when mouse button is released. Return true to consume the event.",
        params: 'params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];'
    },
    {
        name: "MouseEnter",
        description: "Triggered when the mouse cursor enters the control area.",
        params: 'params ["_control"];'
    },
    {
        name: "MouseExit",
        description: "Triggered when the mouse cursor leaves the control area.",
        params: 'params ["_control"];'
    },
    {
        name: "MouseHolding",
        description: "Triggered when the mouse is held stationary over the control.",
        params: 'params ["_control", "_xOffset", "_yOffset"];'
    },
    {
        name: "MouseMoving",
        description: "Triggered when the mouse moves over the control.",
        params: 'params ["_control", "_xOffset", "_yOffset"];'
    },
    {
        name: "MouseZChanged",
        description: "Triggered when the mouse scroll wheel is rotated over the control.",
        params: 'params ["_control", "_scrollAmount"];'
    },
    {
        name: "NavigationWheel",
        description: "Triggered by navigation wheel interaction.",
        params: 'params ["_control", "_delta"];'
    },
    {
        name: "PlayMusic",
        description: "Triggered when music begins playing in UI.",
        params: 'params ["_control", "_musicClass"];'
    },
    {
        name: "PrevNext",
        description: "Triggered on pagination/tab control navigation.",
        params: 'params ["_control", "_direction"];'
    },
    {
        name: "ProgressBarMoved",
        description: "Triggered when progress bar value moves.",
        params: 'params ["_control", "_stepIndex"];'
    },
    {
        name: "SliderPosChanged",
        description: "Triggered when slider or scrollbar position changes.",
        params: 'params ["_control", "_newValue"];'
    },
    {
        name: "TreeCollapsed",
        description: "Triggered when a tree view node is collapsed.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "TreeDblClick",
        description: "Triggered when a tree view item is double-clicked.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "TreeExpanded",
        description: "Triggered when a tree view node is expanded.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "TreeMouseHold",
        description: "Triggered when the mouse is held over a tree view item.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "TreeMouseMove",
        description: "Triggered when the mouse moves over a tree view item.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "TreeSelChanged",
        description: "Triggered when selection in tree view changes.",
        params: 'params ["_control", "_selectionPath"];'
    },
    {
        name: "Unload",
        description: "Triggered when a display is unloaded.",
        params: 'params ["_display", "_exitCode"];'
    },
    {
        name: "VideoStopped",
        description: "Triggered when video playback finishes in RscVideo.",
        params: 'params ["_control"];'
    }
];

export const MP_EVENTS: SqfEventInfo[] = [
    {
        name: "MPHit",
        description: "Triggered globally on all machines when the object takes damage in multiplayer.",
        params: 'params ["_unit", "_causedBy", "_damage", "_instigator"];'
    },
    {
        name: "MPKilled",
        description: "Triggered globally on all machines when the object is killed or destroyed in multiplayer.",
        params: 'params ["_unit", "_killer", "_instigator", "_useEffects"];'
    },
    {
        name: "MPRespawn",
        description: "Triggered globally on all machines when a playable unit respawns in multiplayer.",
        params: 'params ["_unit", "_corpse"];'
    }
];

export const MISSION_EVENTS: SqfEventInfo[] = [
    {
        name: "BuildingChanged",
        description: "Triggered when a building collapses into ruins or is rebuilt.",
        params: 'params ["_previousBuilding", "_newBuilding", "_isRuin"];'
    },
    {
        name: "CommandModeChanged",
        description: "Triggered when player enters or leaves commanding mode.",
        params: 'params ["_isCommandMode"];'
    },
    {
        name: "CommunityEvent",
        description: "Triggered when a custom community event is dispatched.",
        params: 'params ["_eventName", "_eventArgs"];'
    },
    {
        name: "DedicatedServer",
        description: "Triggered on dedicated server startup.",
        params: 'params [];'
    },
    {
        name: "Draw3D",
        description: "Triggered every frame for 3D drawing (drawIcon3D, drawLine3D, etc.).",
        params: 'params [];'
    },
    {
        name: "EachFrame",
        description: "Triggered every frame before rendering (ideal for per-frame updates).",
        params: 'params [];'
    },
    {
        name: "Ended",
        description: "Triggered when mission ends.",
        params: 'params ["_endType"];'
    },
    {
        name: "EntityCreated",
        description: "Triggered when any entity is created in the mission.",
        params: 'params ["_entity"];'
    },
    {
        name: "EntityDeleted",
        description: "Triggered when any entity is deleted from the mission.",
        params: 'params ["_entity"];'
    },
    {
        name: "EntityKilled",
        description: "Triggered when any entity in the mission is killed.",
        params: 'params ["_killed", "_killer", "_instigator", "_useEffects"];'
    },
    {
        name: "EntityRespawned",
        description: "Triggered when any player or entity respawns in the mission.",
        params: 'params ["_newEntity", "_oldEntity"];'
    },
    {
        name: "ExtensionCallback",
        description: "Triggered when an extension callback is received.",
        params: 'params ["_name", "_function", "_data"];'
    },
    {
        name: "GroupCreated",
        description: "Triggered when a new group is created.",
        params: 'params ["_group"];'
    },
    {
        name: "GroupDeleted",
        description: "Triggered when an empty group is deleted.",
        params: 'params ["_group"];'
    },
    {
        name: "HandleDisconnect",
        description: "Triggered on the server when a player disconnects. Return true to delete player unit.",
        params: 'params ["_unit", "_id", "_uid", "_name"];'
    },
    {
        name: "Loaded",
        description: "Triggered when a saved game is loaded.",
        params: 'params ["_saveType"];'
    },
    {
        name: "Map",
        description: "Triggered when the main map is opened or closed.",
        params: 'params ["_mapIsOpened", "_mapIsForced"];'
    },
    {
        name: "MapSingleClick",
        description: "Triggered when player clicks on the map.",
        params: 'params ["_units", "_pos", "_alt", "_shift"];'
    },
    {
        name: "MarkerCreated",
        description: "Triggered when a marker is created.",
        params: 'params ["_marker", "_channel", "_owner", "_local"];'
    },
    {
        name: "MarkerDeleted",
        description: "Triggered when a marker is deleted.",
        params: 'params ["_marker", "_local"];'
    },
    {
        name: "MarkerUpdated",
        description: "Triggered when a marker's properties are updated.",
        params: 'params ["_marker", "_local"];'
    },
    {
        name: "MissionReset",
        description: "Triggered when the mission is restarted or reset.",
        params: 'params [];'
    },
    {
        name: "MuzzleSlotChanged",
        description: "Triggered when weapon muzzle attachment changes.",
        params: 'params ["_unit", "_weapon", "_muzzleSlot", "_item"];'
    },
    {
        name: "OpticsSlotChanged",
        description: "Triggered when weapon optics attachment changes.",
        params: 'params ["_unit", "_weapon", "_opticsSlot", "_item"];'
    },
    {
        name: "PreloadFinished",
        description: "Triggered when mission world preloading finishes.",
        params: 'params [];'
    },
    {
        name: "PreloadStarted",
        description: "Triggered when mission world preloading starts.",
        params: 'params [];'
    },
    {
        name: "SelectedWeaponChanged",
        description: "Triggered when player or unit selects a different weapon.",
        params: 'params ["_unit", "_newWeapon", "_oldWeapon"];'
    },
    {
        name: "SideScore",
        description: "Triggered when a side's score changes.",
        params: 'params ["_side", "_diff"];'
    },
    {
        name: "TeamSwitch",
        description: "Triggered when player uses Team Switch.",
        params: 'params ["_previousUnit", "_newUnit"];'
    },
    {
        name: "UnderFire",
        description: "Triggered when an entity comes under fire.",
        params: 'params ["_unit", "_shooter"];'
    },
    {
        name: "UpperFlashSlotChanged",
        description: "Triggered when weapon flashlight/laser attachment changes.",
        params: 'params ["_unit", "_weapon", "_flashSlot", "_item"];'
    }
];

export function getEventsForCommand(commandName: string): { events: SqfEventInfo[]; categoryName: string } | undefined {
    const cmd = commandName.toLowerCase();
    switch (cmd) {
        case 'addeventhandler':
        case 'removeeventhandler':
        case 'removealleventhandlers':
            return { events: OBJECT_EVENTS, categoryName: 'Object Event' };

        case 'ctrladdeventhandler':
        case 'ctrlremoveeventhandler':
        case 'ctrlremovealleventhandlers':
        case 'ctrlseteventhandler':
        case 'displayaddeventhandler':
        case 'displayremoveeventhandler':
        case 'displayremovealleventhandlers':
        case 'displayseteventhandler':
            return { events: UI_EVENTS, categoryName: 'UI Event' };

        case 'addmpeventhandler':
        case 'removempeventhandler':
        case 'removeallmpeventhandlers':
            return { events: MP_EVENTS, categoryName: 'MP Event' };

        case 'addmissioneventhandler':
        case 'removemissioneventhandler':
        case 'removeallmissioneventhandlers':
            return { events: MISSION_EVENTS, categoryName: 'Mission Event' };

        default:
            return undefined;
    }
}
