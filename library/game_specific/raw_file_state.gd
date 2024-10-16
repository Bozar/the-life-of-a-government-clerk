class_name RawFileState
extends ActorState


var cooldown: int = 0:
    set(value):
        cooldown = max(0, value)
        if cooldown > 0:
            VisualEffect.switch_sprite(sprite, VisualTag.PASSIVE)
        else:
            VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)


var max_cooldown: int = 1:
    set(value):
        max_cooldown = max(1, value)


var send_counter: int = 0:
    set(value):
        send_counter = max(0, value)
