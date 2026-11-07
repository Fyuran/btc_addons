//To be used only in 3DEN editor
class GVAR(module) : Module_F
{
    author = MAIN_AUTHOR;
    scope = 2;
    scopeCurator = 0;
    category = "BTC_Modules";
    displayName = "CAS";
    function = QFUNC(init);
    icon = QPATHTOEF(main,data\iconBtcA.paa);
    isGlobal = 0;
    isDisposable = 1;
    functionPriority = 0;
    isTriggerActivated = 1;
    class ModuleDescription: ModuleDescription
    {
        description = "Sync a trigger to spawn a =BTC= CAS, can be synced to a player unit to allow remote control if enabled";
        sync[] = { "EmptyDetector", "AnyPlayer" };
        optional = 1;	// Synced entity is optional
        direction = 1;
        position = 1;
    };
    class Attributes: AttributesBase
    {
        class GVAR(debug): Default
        {
            displayName = "Enable Debug mode";
            tooltip = "Show debug(Only in Singleplayer)";
            property = QGVAR(debug);
            control = "Checkbox";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(debug),_value)]);
            defaultValue = 0;
            typeName = "BOOL";
        };
        class GVAR(enableDamage): Default
        {
            displayName = "Allow Vehicle damage";
            tooltip = "Change if vehicle can be damaged";
            property = QGVAR(enableDamage);
            control = "Checkbox";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(enableDamage),_value)]);
            defaultValue = "true";
            typeName = "BOOL";
        };
        class GVAR(triggerDistance): Default
        {
            displayName = "Minimum Fire Distance";
            tooltip = "Adjust at which distance vehicle will start its attack";
            property = QGVAR(triggerDistance);
            control = "Edit";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(triggerDistance),_value)]);
            defaultValue = "1500";
            validate = "number";
            typeName = "NUMBER";
        };
        class GVAR(duration): Default
        {
            displayName = "Duration";
            tooltip = "Adjust dive duration in seconds";
            property = QGVAR(duration);
            control = "Edit";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(duration),_value)]);
            defaultValue = "15";
            validate = "number";
            typeName = "NUMBER";
        };
        class GVAR(dispersion): Default
        {
            displayName = "Dispersion";
            tooltip = "Adjust projectiles precision in meters";
            property = QGVAR(dispersion);
            control = "Edit";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(dispersion),_value)]);
            defaultValue = "10";
            validate = "number";
            typeName = "NUMBER";
        };
        class GVAR(distance): Default
        {
            displayName = "Spawn Distance";
            tooltip = "Adjust how far vehicle will spawn in meters";
            property = QGVAR(distance);
            control = "Edit";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(distance),_value)]);
            defaultValue = "3000";
            validate = "number";
            typeName = "NUMBER";
        };
        class GVAR(height): Default
        {
            displayName = "Spawn Height";
            tooltip = "Adjust the height of vehicle spawn in meters";
            property = QGVAR(height);
            control = "Edit";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(height),_value)]);
            defaultValue = "2000";
            validate = "number";
            typeName = "NUMBER";
        };
        class GVAR(remote): Default
        {
            displayName = "Remote Control";
            tooltip = "Check if you want to remote control";
            property = QGVAR(remoteControl);
            control = "Checkbox";
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(remoteControl),_value)]);
            defaultValue = "false";
            typeName = "BOOL";
        };
        class GVAR(remoteHelper): Default
        {
            displayName = "Remote Control Marker";
            tooltip = "Check if you want to show remote control marker";
            property = QGVAR(remoteHelper);
            control = "Checkbox";
            expression = QUOTE(_this setVariable [ARR_3(QQGVAR(remoteHelper),_value,true)]);
            defaultValue = "false";
            typeName = "BOOL";
        };
        class GVAR(vehicleData): Default
        { //Will also hold combo for vehicle class
            displayName = "Vehicle Class";
            tooltip = "Select aircraft class";
            property = QGVAR(vehicleData);
            control = QGVAR(vehicleData);
            expression = QUOTE(_this setVariable [ARR_2(QQGVAR(vehicleData),_value)]);
            defaultValue = "''";
        };
        class ModuleDescription: ModuleDescription {};
    };
};

class GVAR(module_curator): GVAR(module)
{
    scope = 1;
    scopeCurator = 2;
    isTriggerActivated = 0;
    curatorCanAttach = 1; //makes curatorMouseOver less buggy
    model = "\a3\Modules_F_Curator\CAS\surfaceGunMissile.p3d";
    simulation = "house";
    function = QFUNC(curator_init);
    class ModuleDescription: ModuleDescription
    {
        sync[] = { "AnyPlayer" };
    };
};
