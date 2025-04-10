class_name HandlePhoneBooth


static func switch_examine_mode(
        is_enter: bool, phone_booth_sprites: Array[Sprite2D]
        ) -> void:
    var visual_tag: StringName

    for i: Sprite2D in phone_booth_sprites:
        if is_enter:
            visual_tag = VisualTag.ACTIVE
        else:
            visual_tag = VisualTag.DEFAULT
        VisualEffect.switch_sprite(i, visual_tag)

