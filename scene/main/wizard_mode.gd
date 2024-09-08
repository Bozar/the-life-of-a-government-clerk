class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var carts: Array
    var visual_tags: Array = [
        VisualTag.ACTIVE_1,
        VisualTag.ACTIVE_2,
        VisualTag.ACTIVE_3,
        VisualTag.ACTIVE_4,
        VisualTag.PASSIVE,
    ]
    var head_cart: Sprite2D

    match input_tag:
        InputTag.WIZARD_1:
            get_node("../Cart").add_cart(3)
        InputTag.WIZARD_2:
            carts = SpriteState.get_sprites_by_sub_tag(SubTag.CART)
            if carts.size() > 5:
                carts.resize(5)
            for i in range(0, carts.size()):
                VisualEffect.switch_sprite(carts[i], visual_tags[i])
        InputTag.WIZARD_3:
            head_cart = SpriteState.get_sprites_by_sub_tag(SubTag.PC)[0]
            carts = SpriteState.get_sprites_by_sub_tag(SubTag.CART)
            get_node("../Cart")._remove_cart(head_cart, carts[0])
