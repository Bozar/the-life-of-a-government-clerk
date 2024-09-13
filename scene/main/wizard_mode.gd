class_name WizardMode
extends Node2D


var _counter: int


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var ref_cart: Cart = get_node("../Cart")
    var pc: Sprite2D = SpriteState.get_sprites_by_sub_tag(SubTag.PC)[0]
    var cart: Sprite2D
    var state: CartState

    match input_tag:
        InputTag.WIZARD_1:
            ref_cart.add_cart(GameData.ADD_CART)
        InputTag.WIZARD_2:
            cart = ref_cart.get_last_slot(pc)
            if cart == null:
                return
            state = ref_cart.get_state(cart)
            match _counter:
                0:
                    state.item_tag = SubTag.ATLAS
                1:
                    state.item_tag = SubTag.ATLAS
                2:
                    state.item_tag = SubTag.BOOK
                3:
                    state.item_tag = SubTag.CUP
                4:
                    state.item_tag = SubTag.DOCUMENT
                5:
                    state.item_tag = SubTag.ENCYCLOPEDIA
                6, _:
                    _counter = 0
                    return
            state.load_factor = 100 - _counter * 20
            _counter += 1
        InputTag.WIZARD_3:
            cart = ref_cart.get_first_item(pc)
            if cart == null:
                return
            state = ref_cart.get_state(cart)
            state.item_tag = SubTag.CART
        InputTag.WIZARD_4:
            print(ref_cart.clean_cart(pc))
