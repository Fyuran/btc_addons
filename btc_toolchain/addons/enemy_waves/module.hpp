class GVAR(module) : Module_F
{
    author = MAIN_AUTHOR;
    scope = 2;
    scopeCurator = 0;
    isTriggerActivated = 1;				// 1 for module waiting until all synced triggers are activated
    isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
    category = "BTC_Modules";
    displayName = "Enemy Waves";
    function = QFUNC(spawn_begin);
    icon = QPATHTOEF(main,data\iconBtcA.paa);
    isGlobal = 0;
    class ModuleDescription: ModuleDescription
    {
        description = "Sync a trigger and initiate a =BTC= enemy waves incursion against the closest player who activated the trigger, with passed values, you can also sync =BTC= enemy waves waypoints modules to lead the waves before approaching a enemy character";
        sync[] = { "EmptyDetector" };	
    };
    class Attributes : AttributesBase
    {
        class GVAR(side): Default
        {
            displayName = "Side"; // Name assigned to UI control class Title
            tooltip = "Change enemies' side"; // Tooltip assigned to UI control class Title
            property = QGVAR(side); // Unique config property name saved in SQM
            control = QGVAR(side); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
            // Expression called when applying the attribute in Eden and at the scenario start
            // The expression is called twice - first for data validation, and second for actual saving
            // Entity is passed as _this, value is passed as _value
            // In MP scenario, the expression is called only on server.
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(side),_value)]);
            // Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
            // Must be of type string
            // Entity (unit, group, marker, comment etc.) is passed as _this
            // Returned value is the default value
            // Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
            // Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
            defaultValue = "OPFOR";
            //--- Optional properties
            //unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
            //validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
            //typeName = "NUMBER"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
        };
        class GVAR(timeout): Default
        {
            displayName = "Delay";
            tooltip = "How long module will wait to spawn next wave";
            property = QGVAR(timeout);
            control = QGVAR(timeout);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(timeout),_value)]);
            defaultValue = "60";
            typeName = "NUMBER";
        };
        class GVAR(seek_end): Default
        {
            displayName = "Seek out nearest player";
            tooltip = "With all waypoints exhausted or none present, seek enemy players";
            property = QGVAR(seek_end);
            control = QGVAR(seek_end);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(seek_end),_value)]);
            defaultValue = "true";
            typeName = "BOOL";
        };
        class GVAR(presets): Default
        {
            property = QGVAR(presets);
            control = QGVAR(presets);
            expression = QUOTE(_data = [GVAR(table)] call EFUNC(gui,list_attributeSave); _this setVariable[ARR_2(QQGVAR(list_value),_data)]);
            defaultValue = "''";
            typeName = "STRING"; 
        };
        class ModuleDescription : ModuleDescription {};
    };
};

class GVAR(module_curator) : GVAR(module)
{
    scope = 1;
    scopeCurator = 2;
    function = QFUNC(curator_init);
    isTriggerActivated = 0;
};

class GVAR(waypoint_module) : Module_F
{
    author = MAIN_AUTHOR;
    scope = 2;
    scopeCurator = 0;
    category = "BTC_Modules";
    displayName = "Enemy Waves Waypoint";
    //function = QFUNC(wp_moduleInit);
    icon = QPATHTOEF(main,data\iconBtcA.paa);
    isGlobal = 0;
    class ModuleDescription: ModuleDescription
    {
        description = "Waypoints for the =BTC= Enemy waves module";
    };
    class Attributes : AttributesBase
    {
        class GVAR(type): Default
        {
            displayName = "Type";
            tooltip = "Type of waypoint";
            property = QGVAR(type_data);
            control = QGVAR(wp_type);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(type_data),_value)]);
            defaultValue = "[[], 'MOVE']";
        };
        class GVAR(combat_mode): Default
        {
            displayName = "Combat Mode";
            tooltip = "Waypoint combat mode";
            property = QGVAR(combat_mode);
            control = QGVAR(CombatModeWaypoint);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(combat_mode),_value)]);
            defaultValue = "'NO CHANGE'";
        };
        class GVAR(behavior): Default
        {
            displayName = "Behaviour Mode";
            tooltip = "Waypoint behaviour mode";
            property = QGVAR(behavior);
            control = QGVAR(BehaviourWaypoint);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(behavior),_value)]);
            defaultValue = "'UNCHANGED'";
        };
        class GVAR(formation): Default
        {
            displayName = "Formation";
            tooltip = "Waypoint formation";
            property = QGVAR(formation);
            control = QGVAR(FormationWaypoint);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(formation),_value)]);
            defaultValue = "'no change'";
        };
        class GVAR(speed): Default
        {
            displayName = "Speed Mode";
            tooltip = "Waypoint speed mode";
            property = QGVAR(speed);
            control = QGVAR(SpeedModeWaypoint);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(speed),_value)]);
            defaultValue = "'unchanged'";
        };
        class GVAR(file): Default
        {
            displayName = "File Path";
            tooltip = "File path for scripted waypoints";
            property = QGVAR(file);
            control = QGVAR(File);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(file),_value)]);
            defaultValue = "''";
            typeName = "STRING";
        };
        class GVAR(completion_radius): Default
        {
            displayName = "Completion Radius";
            tooltip = "How far from waypoint can group be to complete waypoint";
            property = QGVAR(completion_radius);
            control = QGVAR(completion_radius);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(completion_radius),_value)]);
            defaultValue = "0";
            validate = "number";
            typeName = "NUMBER";
        };
        class ModuleDescription : ModuleDescription {};
    };
};
