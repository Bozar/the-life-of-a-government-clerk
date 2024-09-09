class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var carts: Array
    var head_cart: Sprite2D
    var cart: Sprite2D
    var cart_state: CartState

    match input_tag:
        InputTag.WIZARD_1:
            get_node("../Cart").add_cart(7)
        InputTag.WIZARD_2:
            carts = SpriteState.get_sprites_by_sub_tag(SubTag.CART)
            if carts.size() > 6:
                carts.resize(6)
            for i in range(0, carts.size()):
                cart = carts[i]
                cart_state = get_node("../Cart").get_state(cart)
                match i:
                    0:
                        cart_state.item_tag = SubTag.ATLAS
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
                    1:
                        cart_state.item_tag = SubTag.BOOK
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
                    2:
                        cart_state.item_tag = SubTag.CUP
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
                    3:
                        cart_state.item_tag = SubTag.DOCUMENT
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
                    4:
                        cart_state.is_discarded = true
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
                    5:
                        cart_state.load_factor = 120
                        VisualEffect.switch_sprite(cart, cart_state.visual_tag)
        InputTag.WIZARD_3:
            head_cart = SpriteState.get_sprites_by_sub_tag(SubTag.PC)[0]
            carts = SpriteState.get_sprites_by_sub_tag(SubTag.CART)
            get_node("../Cart")._remove_cart(head_cart, carts[0])
