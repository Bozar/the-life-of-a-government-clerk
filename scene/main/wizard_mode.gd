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
    var clerk_state: ClerkState
    var service_state: ServiceState

    match input_tag:
        InputTag.WIZARD_1:
            # ref_pc_action.account += 1
            Cart.add_cart(GameData.ADD_CART, linked_state)
        InputTag.WIZARD_2:
            cart = Cart.get_last_slot(pc, linked_state)
            if cart == null:
                return
            cart_state = Cart.get_state(cart, linked_state)
            cart_state.item_tag = SubTag.ATLAS
            cart_state.load_factor = 20
        InputTag.WIZARD_3:
            cart = Cart.get_first_item(pc, linked_state)
            if cart == null:
                return
            cart_state = Cart.get_state(cart, linked_state)
            cart_state.item_tag = SubTag.CART
        InputTag.WIZARD_4:
            sprite = SpriteState.get_sprites_by_sub_tag(SubTag.CLERK)[0]
            clerk_state = actor_action._get_actor_state(sprite)
            clerk_state.progress = 999
        InputTag.WIZARD_5:
            sprite = SpriteState.get_sprites_by_sub_tag(SubTag.SERVICE)[0]
            service_state = actor_action._get_actor_state(sprite)
            match _counter:
                0:
                    service_state.service_type = ServiceState.CART
                    _counter += 1
                1:
                    service_state.service_type = ServiceState.ORDER
                    _counter += 1
                _:
                    service_state.service_type = ServiceState.STICK
                    _counter = 0
