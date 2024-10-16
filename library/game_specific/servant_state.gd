class_name ServantState
extends ActorState


var idle_duration: int = 0:
    set(value):
        idle_duration = value
        if is_active:
            VisualEffect.switch_sprite(sprite, VisualTag.ACTIVE)
        else:
            VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)


var max_idle_duration: int:
    set(value):
        max_idle_duration = max(1, value)


var is_active: bool:
    get:
        return idle_duration > max_idle_duration
