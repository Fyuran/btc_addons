class Default;
class Title: Default
{
    class Controls
    {
        class Title: ctrlStatic {};
    };
};
class Combo: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlCombo {};
    };
};
class Checkbox: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlCheckboxBaseline {};
    };
};
class Edit: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlEdit {};
    };
};
class Type: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Search: ctrlEdit {};
        class SearchButton: ctrlButtonSearch {};
        class Value: ctrlTree {};
    };
};
class Toolbox: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlToolbox {};
    };
};

class CombatModeGroup: Combo
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: Value
        {
            class Items
            {
                class Blue {};
                class Green {};
                class White {};
                class Yellow {};
                class Red {};
            };
        };
    };
};
class CombatModeWaypoint: CombatModeGroup
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: Value
        {
            class Items: Items
            {
                class NoChange {};
                class Blue: Blue {};
                class Green: Green {};
                class White: White {};
                class Yellow: Yellow {};
                class Red: Red {};
            };
        };
    };
};
class BehaviourGroup: Combo
{
    class Controls: Controls
    {
        class Title: Title
        {
        };
        class Value: Value
        {
            class Items
            {
                class Careless {};
                class Safe {};
                class Aware {};
                class Combat {};
                class Stealth {};
            };
        };
    };
};
class BehaviourWaypoint: BehaviourGroup
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: Value
        {
            class Items: Items
            {
                class Unchanged {};
                class Careless: Careless {};
                class Safe: Safe {};
                class Aware: Aware {};
                class Combat: Combat {};
                class Stealth: Stealth {};
            };
        };
    };
};
class FormationWaypoint: Toolbox
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: Value {};
    };
};
class SpeedModeWaypoint: Toolbox
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: Value {};
    };
};
