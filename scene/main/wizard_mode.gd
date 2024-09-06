class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    match input_tag:
        InputTag.WIZARD_1:
            _test(input_tag)


func _test(input_tag: StringName) -> void:
    var sprite: Sprite2D
    var visual_tags: Array = [
        VisualTag.DEFAULT,
        VisualTag.ACTIVE_1,
        VisualTag.ACTIVE_2,
        VisualTag.ACTIVE_3,
        VisualTag.ACTIVE_4,
        VisualTag.PASSIVE,
        VisualTag.ZERO,
        VisualTag.ONE,
        VisualTag.TWO,
        VisualTag.THREE,
        VisualTag.FOUR,
        VisualTag.FIVE,
        VisualTag.SIX,
        VisualTag.SEVEN,
        VisualTag.EIGHT,
        VisualTag.NINE,
    ]

    match input_tag:
        InputTag.WIZARD_1:
            for i in range(0, visual_tags.size()):
                sprite = SpriteFactory.create_actor(SubTag.CART, Vector2i(i, 0),
                    true).sprite
                VisualEffect.switch_sprite(sprite, visual_tags[i])
