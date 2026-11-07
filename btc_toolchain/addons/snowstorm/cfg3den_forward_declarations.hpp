class Default;
class Title: Default
{
    class Controls
    {
        class Title: ctrlStatic {};
    };
};
class Slider: Title
{
    class Controls: Controls
    {
        class Title: Title {};
        class Value: ctrlXSliderH {};
        class Edit: ctrlEdit {};
    };
};
