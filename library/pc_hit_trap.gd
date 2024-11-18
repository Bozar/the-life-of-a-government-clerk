class_name PcHitTrap


static func handle_input(
        trap: Sprite2D, ref_PcAction: PcAction, ref_RandomNumber: RandomNumber,
        ref_Schedule: Schedule
        ) -> void:
    var trap_coord: Vector2i = ConvertCoord.get_coord(trap)
    var pc: Sprite2D = ref_PcAction.pc
    var linked_cart_state: LinkedCartState = ref_PcAction.linked_cart_state
    var count_cart: int = Cart.count_cart(linked_cart_state)
    var delay: int = Cart.get_delay_duration(pc, linked_cart_state)

    if count_cart < GameData.CART_LENGTH_SHORT:
        ref_PcAction.delay = delay
    else:
        if _remove_servant(pc, linked_cart_state):
            pass
        else:
            ref_PcAction.delay = delay

    SpriteFactory.remove_sprite(trap)
    Cart.pull_cart(pc, trap_coord, linked_cart_state)
    Cart.add_draft(pc, linked_cart_state, ref_RandomNumber)
    ref_Schedule.start_next_turn()


static func _remove_servant(
        pc: Sprite2D, linked_state: LinkedCartState
        ) -> bool:
    var first_item: Sprite2D = Cart.get_first_item(pc, linked_state)
    var state: CartState

    if first_item == null:
        return false

    state = Cart.get_state(first_item, linked_state)
    if state.item_tag == SubTag.SERVANT:
        state.item_tag = SubTag.CART
        return true
    return false
