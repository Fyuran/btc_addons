class GVAR(module) : Module_F
{
    author = MAIN_AUTHOR;
    scope = 2;
    scopeCurator = 0;
    isTriggerActivated = 1;				// 1 for module waiting until all synced triggers are activated
    isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
    is3DEN = 0; //execute in 3den editor
    category = "BTC_Modules";
    displayName = "Supply";
    function = QFUNC(drop);
    icon = QPATHTOEF(main,data\iconBtcA.paa);
    isGlobal = 0; // 0 for server only execution, 1 for global execution, 2 for persistent global execution
    class ModuleDescription: ModuleDescription
    {
        description = "Sync a trigger and initiate a =BTC= supply drop with passed values";
        sync[] = { "EmptyDetector" };	
    };
    class Attributes : AttributesBase
    {
        class GVAR(vehicleClass): Default
        {
            displayName = "Vehicle class"; // Name assigned to UI control class Title
            tooltip = "Change vehicle carrying supplies"; // Tooltip assigned to UI control class Title
            property = QGVAR(vehicleClass); // Unique config property name saved in SQM
            control = QGVAR(vehicleClass); // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes
            // Expression called when applying the attribute in Eden and at the scenario start
            // The expression is called twice - first for data validation, and second for actual saving
            // Entity is passed as _this, value is passed as _value
            // btc_toolchain_supply_class is replaced by attribute config name. It can be used only once in the expression
            // In MP scenario, the expression is called only on server.
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(vehicleClass),_value)]);
            // Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
            // Must be of type string
            // Entity (unit, group, marker, comment etc.) is passed as _this
            // Returned value is the default value
            // Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
            // Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
            defaultValue = "''";
            //--- Optional properties
            //unique = 0; // When 1, only one entity of the type can have the value in the mission (used for example for variable names or player control)
            //validate = "number"; // Validate the value before saving. Can be "none", "expression", "condition", "number" or "variable"
            typeName = "STRING"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
        };
        class GVAR(enableDamage): Default
        {
            displayName = "Allow Vehicle damage";
            tooltip = "Change if vehicle can be damaged";
            property = QGVAR(enableDamage);
            control = QGVAR(enableDamage);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(enableDamage),_value)]);
            defaultValue = "true";
            typeName = "BOOL";
        };
         class GVAR(debug): Default
        {
            displayName = "Debug";
            tooltip = "Show debug";
            property = QGVAR(debug);
            control = "Checkbox";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(debug),_value)]);
            defaultValue = "false";
            typeName = "BOOL";
        };
        class GVAR(presets): Default
        {
            property = QGVAR(presets);
            control = QGVAR(presets);
            expression = QUOTE(_this setVariable[ARR_2(QQGVAR(list_value),_value)]);
            defaultValue = "''";
            typeName = "STRING"; 
        };
        class ModuleDescription : ModuleDescription {};
    };
};

class GVAR(module_curator): GVAR(module)
{
    scope = 1;
    scopeCurator = 2;
    isTriggerActivated = 0;
    function = QFUNC(curator_init);
};
