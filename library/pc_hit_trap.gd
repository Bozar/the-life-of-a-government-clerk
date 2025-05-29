class_name PcHitTrap


static func handle_input(
		trap: Sprite2D, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber, ref_Schedule: Schedule
) -> void:
	var trap_coord: Vector2i = ConvertCoord.get_coord(trap)
	var pc: Sprite2D = ref_DataHub.pc
	var linked_cart_state: LinkedCartState = ref_DataHub.linked_cart_state
	var count_cart: int = Cart.count_cart(linked_cart_state)
	var delay: int = get_delay_duration()

	if count_cart < GameData.CART_LENGTH_SHORT:
		ref_DataHub.delay = delay
	else:
		if _remove_servant(pc, linked_cart_state):
			pass
		else:
			ref_DataHub.delay = delay

	SpriteFactory.remove_sprite(trap)
	Cart.pull_cart(pc, trap_coord, linked_cart_state)
	Cart.add_trash(pc, linked_cart_state, ref_RandomNumber)
	ref_Schedule.start_next_turn()


static func get_delay_duration() -> int:
	var delay: int = GameData.BASE_DELAY
	var pc: Sprite2D = NodeHub.ref_DataHub.pc
	var state: LinkedCartState = NodeHub.ref_DataHub.linked_cart_state

	delay += NodeHub.ref_DataHub.count_idler
	delay += Cart.get_delay_duration(pc, state)
	return delay


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

