class_name WizardMode
extends Node2D


var _counter: int


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var ref_pc_action: PcAction = get_node("..")
    var pc: Sprite2D = SpriteState.get_sprites_by_sub_tag(SubTag.PC)[0]
    var actor_action: ActorAction = get_node("../../ActorAction")
    var cart: Sprite2D
    var linked_state: LinkedCartState = ref_pc_action._linked_cart_state
    var cart_state: CartState
    var sprite: Sprite2D

    match input_tag:
        InputTag.WIZARD_1:
            ref_pc_action.account += 1
            Cart.add_cart(GameData.ADD_CART, linked_state)
            # ref_pc_action.has_stick = true
            # sprite = SpriteState.get_sprites_by_sub_tag(SubTag.SERVICE)[0]
        InputTag.WIZARD_2:
            cart = Cart.get_last_slot(pc, linked_state)
            if cart == null:
                return
            cart_state = Cart.get_state(cart, linked_state)
            match _counter:
                0:
                    cart_state.item_tag = SubTag.ATLAS
                1:
                    cart_state.item_tag = SubTag.ATLAS
                2:
                    cart_state.item_tag = SubTag.BOOK
                3:
                    cart_state.item_tag = SubTag.CUP
                4:
                    cart_state.item_tag = SubTag.DOCUMENT
                5:
                    cart_state.item_tag = SubTag.ENCYCLOPEDIA
                6, _:
                    _counter = 0
                    return
            cart_state.load_factor = 100 - _counter * 20
            _counter += 1
        InputTag.WIZARD_3:
            cart = Cart.get_first_item(pc, linked_state)
            if cart == null:
                return
            cart_state = Cart.get_state(cart, linked_state)
            cart_state.item_tag = SubTag.CART
        InputTag.WIZARD_4:
            # print(Cart.clean_cart(pc, linked_state))
            cart = Cart.get_last_slot(pc, linked_state)
            if cart == null:
                return
            cart_state = Cart.get_state(cart, linked_state)
            cart_state.item_tag = SubTag.DOCUMENT
