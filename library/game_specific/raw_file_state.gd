class_name RawFileState
extends ActorState


var cooldown: int = 0:
    set(value):
        cooldown = max(0, value)
        if cooldown > 0:
            VisualEffect.switch_sprite(sprite, VisualTag.PASSIVE)
        else:
            if sub_tag == SubTag.ENCYCLOPEDIA:
                _switch_encyclopedia_sprite()
            else:
                VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)


var max_cooldown: int = 1:
    set(value):
        max_cooldown = max(1, value)


var send_counter: int = 0:
    set(value):
        send_counter = max(0, value)


func _switch_encyclopedia_sprite() -> void:
    var visual_tag: StringName = VisualTag.DEFAULT
    var count_cart: int = SpriteState.get_sprites_by_sub_tag(SubTag.CART).size()

    if count_cart < GameData.CART_LENGTH_LONG:
        visual_tag = VisualTag.PASSIVE
    VisualEffect.switch_sprite(sprite, visual_tag)
