class Default;
class Title: Default
{
    class Controls
    {
        class Title: ctrlStatic {};
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
class Toolbox: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlToolbox {};
    };
};
