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
