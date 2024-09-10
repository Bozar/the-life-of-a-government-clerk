class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var pc: Sprite2D = SpriteState.get_sprites_by_sub_tag(SubTag.PC)[0]
    var carts: Array
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
                        cart_state.load_factor = i * 20
                    1:
                        cart_state.item_tag = SubTag.BOOK
                        cart_state.load_factor = i * 20
                    2:
                        cart_state.item_tag = SubTag.CUP
                        cart_state.load_factor = i * 20
                    3:
                        cart_state.item_tag = SubTag.DOCUMENT
                        cart_state.load_factor = i * 20
                    4:
                        cart_state.is_dropped = true
                        cart_state.load_factor = i * 20
                    5:
                        cart_state.load_factor = 120
        InputTag.WIZARD_3:
            carts = SpriteState.get_sprites_by_sub_tag(SubTag.CART)
            get_node("../Cart")._remove_cart(pc, carts[0])
        InputTag.WIZARD_4:
            cart = get_node("../Cart").get_last_slot(pc)
            if cart != null:
                cart_state = get_node("../Cart").get_state(cart)
                cart_state.item_tag = SubTag.CUP
