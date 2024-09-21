class_name RawFileState
extends ActorState


var cooldown: int = 0:
    set(value):
        cooldown = max(0, value)
        if cooldown > 0:
            VisualEffect.switch_sprite(_sprite, VisualTag.PASSIVE)
        else:
            VisualEffect.switch_sprite(_sprite, VisualTag.DEFAULT)
