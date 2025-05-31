class_name Cart
extends Node2D


enum SAFE_LOAD {
	LAST_SLOT,
	FULL_LINE,
}

const EXTEND_TEMPLATE: String = "$> +%s"
const EXAMINE_TEMPLATE: String = "?> %s: %s%%"
const FIRST_ITEM_TEMPLATE: String = "1> %s: %s%%"
const LAST_SLOT_TEMPLATE: String = "$> %s: %s%%"
const NO_LAST_SLOT: String = "$> -: -%"

const PERCENT: float = 100.0

const ITEM_TO_STRING: Dictionary = {
	SubTag.CART: "-",
	SubTag.ATLAS: "A",
	SubTag.BOOK: "B",
	SubTag.CUP: "C",
	SubTag.DOCUMENT: "D",
	SubTag.ENCYCLOPEDIA: "E",
	SubTag.FIELD_REPORT: "F",
	SubTag.SERVANT: "S",
}

# By game design, `DETACHED` and `FULL` only appears in Examine Mode.
const DETACHED: String = "?> DETACHED"
const FULL: String = "?> FULL"


static func init_linked_carts(
		head_cart: Sprite2D, state: LinkedCartState
) -> void:
	state.linked_carts = LinkedList.init_list(head_cart)


static func add_cart(new_cart_count: int, state: LinkedCartState) -> void:
	state.add_cart_counter += new_cart_count


static func count_cart(state: LinkedCartState) -> int:
	# There is exactly 1 PC and 0+ carts in `state.linked_carts`.
	return state.linked_carts.size() - 1


static func get_state(cart: Sprite2D, state: LinkedCartState) -> CartState:
	var cart_state: CartState = state.cart_states.get(
			cart.get_instance_id(), null
	)

	if cart_state == null:
		push_error("Cart state not found: %s" % cart.name)
	return cart_state


static func pull_cart(
		first_cart: Sprite2D, first_target_coord: Vector2i,
		state: LinkedCartState
) -> void:
	var last_cart: Sprite2D
	var last_coord: Vector2i
	var remove: Sprite2D

	# Remove carts first, in order to pull fewer carts if possible.
	while state.save_detached_carts.size() > 0:
		remove = state.save_detached_carts.pop_back()
		_remove_cart(first_cart, remove, state)

	# Before moving the newer (perhaps shorter) cart line, record the
	# position of the last cart.
	last_cart = LinkedList.get_previous_object(
			first_cart, state.linked_carts
	)
	last_coord = ConvertCoord.get_coord(last_cart)

	# Move the cart line. Add a new cart to the recorded position if
	# requried.
	_move_cart(first_cart, first_cart, first_target_coord, state)
	_add_cart_deferred(first_cart, last_coord, state)


static func get_first_item(pc: Sprite2D, state: LinkedCartState) -> Sprite2D:
	var cart: Sprite2D = pc
	var cart_state: CartState

	while true:
		# All carts have been examined.
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			return null
		# Find the first cart (starting from PC) that carries an item.
		cart_state = get_state(cart, state)
		if cart_state == null:
			continue
		elif cart_state.is_detached:
			continue
		elif cart_state.is_full:
			continue
		elif cart_state.item_tag == SubTag.CART:
			continue
		break
	return cart


static func get_last_slot(pc: Sprite2D, state: LinkedCartState) -> Sprite2D:
	var cart: Sprite2D = pc
	var cart_state: CartState

	while true:
		# All carts have been examined.
		cart = LinkedList.get_previous_object(cart, state.linked_carts)
		if cart == pc:
			return null
		# Find the last cart (starting from PC) that is empty.
		cart_state = get_state(cart, state)
		if cart_state == null:
			continue
		elif cart_state.is_detached:
			continue
		elif cart_state.is_full:
			continue
		elif cart_state.item_tag != SubTag.CART:
			continue
		break
	return cart


# By game design, return true if at least one cart is cleaned or detached, and
# therefore charge a small fee.
static func clean_cart(pc: Sprite2D, state: LinkedCartState) -> bool:
	var is_cleaned: bool = false
	var cart: Sprite2D = pc
	var cart_state: CartState

	# Note that the first cart is 0.
	for i: int in range(0, state.linked_carts.size()):
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		# All carts have been examined.
		if cart == pc:
			break
		cart_state = get_state(cart, state)
		# This should not happen.
		if cart_state == null:
			continue
		# By game design, the first few carts can be cleaned, but not
		# detached.
		elif i < GameData.MIN_CART:
			# This should not happen.
			if cart_state.is_detached:
				continue
			elif cart_state.load_amount > GameData.MIN_LOAD:
				cart_state.load_amount = GameData.MIN_LOAD
				is_cleaned = true
		# By game design, trailing carts can be detached, but not
		# cleaned.
		else:
			# This could happen.
			if cart_state.is_detached:
				continue
			elif cart_state.is_full:
				cart_state.is_detached = true
				is_cleaned = true
				state.save_detached_carts.push_back(cart)
	return is_cleaned


static func clean_short_cart(
		pc: Sprite2D, state: LinkedCartState, remove_load: int
) -> void:
	var cart: Sprite2D = pc
	var cart_state: CartState

	# Only clean the first three carts.
	for i: int in range(0, GameData.MIN_CART):
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		# There are fewer than three carts for some reason.
		if cart == pc:
			break
		cart_state = get_state(cart, state)
		# This should not happen.
		if cart_state == null:
			continue

		remove_load -= cart_state.load_amount
		if remove_load > 0:
			cart_state.load_amount = 0
		else:
			cart_state.load_amount = -remove_load
			break


static func get_full_load_amount(pc: Sprite2D, state: LinkedCartState) -> int:
	var cart: Sprite2D = pc
	var cart_state: CartState
	var load_amount: int = 0

	while true:
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			break

		cart_state = get_state(cart, state)
		load_amount += cart_state.load_amount

	return load_amount


static func get_all_item_tag(pc: Sprite2D, state: LinkedCartState) -> Array:
	var cart: Sprite2D = pc
	var cart_state: CartState
	var item_tags: Array

	while true:
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			break

		cart_state = get_state(cart, state)
		item_tags.push_back(cart_state.item_tag)

	return item_tags


static func get_delay_duration(pc: Sprite2D, state: LinkedCartState) -> int:
	var full_load: int = get_full_load_amount(pc, state)
	var load_factor: float

	if count_cart(state) <= GameData.CART_LENGTH_SHORT:
		load_factor = GameData.LOAD_FACTOR_SHORT
	else:
		load_factor = GameData.LOAD_FACTOR_LONG
	return floor(full_load * load_factor / GameData.MAX_LOAD_PER_CART)


static func count_item(
		item_tag: StringName, pc: Sprite2D, state: LinkedCartState
) -> int:
	var cart: Sprite2D = pc
	var cart_state: CartState
	var count: int = 0

	while true:
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			break

		cart_state = get_state(cart, state)
		if cart_state.item_tag == item_tag:
			count += 1

	return count


static func remove_all_item(
		item_tag: StringName, pc: Sprite2D, state: LinkedCartState
) -> bool:
	var cart: Sprite2D = pc
	var cart_state: CartState
	var is_removed: bool = false

	while true:
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			break

		cart_state = get_state(cart, state)
		if cart_state.item_tag == item_tag:
			cart_state.item_tag = SubTag.CART
			is_removed = true

	return is_removed


static func add_trash(
		pc: Sprite2D, state: LinkedCartState,
		ref_RandomNumber: RandomNumber
) -> void:
	var cart: Sprite2D = pc
	var cart_state: CartState
	var load_index: int = ref_RandomNumber.get_int(
			0, GameData.ADD_LOADS.size()
	)
	var add_loads: Array = GameData.ADD_LOADS[load_index]
	var add_counter: int = 0

	while true:
		cart = LinkedList.get_next_object(cart, state.linked_carts)
		if cart == pc:
			break
		cart_state = get_state(cart, state)

		if SpriteState.get_ground_by_coord(
				ConvertCoord.get_coord(cart),
				GameData.INTERNAL_FLOOR_Z_LAYER
		) != null:
			continue
		elif cart_state.is_full:
			continue
		elif add_counter > add_loads.size() - 1:
			break

		if cart_state.item_tag == SubTag.SERVANT:
			cart_state.load_amount += GameData.MIN_LOAD_PER_TURN
		else:
			cart_state.load_amount += add_loads[add_counter]
		add_counter += 1


static func enter_examine_mode(pc: Sprite2D, state: LinkedCartState) -> bool:
	# There should be at least two sprites (PC and cart) to enable examine
	# mode.
	if state.linked_carts.size() < 2:
		return false

	var target_cart: Sprite2D = LinkedList.get_next_object(pc,
			state.linked_carts)
	var target_coord: Vector2i = ConvertCoord.get_coord(target_cart)

	state.save_pc_coord = ConvertCoord.get_coord(pc)
	# By game design, PC can move over cart sprites.
	SpriteState.move_sprite(pc, target_coord, pc.z_index + 1)
	VisualEffect.switch_sprite(pc, VisualTag.PASSIVE)
	return true


static func exit_examine_mode(pc: Sprite2D, state: LinkedCartState) -> void:
	SpriteState.move_sprite(pc, state.save_pc_coord, pc.z_index - 1)
	VisualEffect.switch_sprite(pc, VisualTag.DEFAULT)


static func examine_first_cart(pc: Sprite2D, state: LinkedCartState) -> void:
	var cart: Sprite2D = LinkedList.get_next_object(pc, state.linked_carts)
	var coord: Vector2i = ConvertCoord.get_coord(cart)

	SpriteState.move_sprite(pc, coord)


static func examine_last_cart(pc: Sprite2D, state: LinkedCartState) -> void:
	var cart: Sprite2D = LinkedList.get_previous_object(
			pc, state.linked_carts
	)
	var coord: Vector2i = ConvertCoord.get_coord(cart)
	SpriteState.move_sprite(pc, coord)


static func examine_next_cart(pc: Sprite2D, state: LinkedCartState) -> void:
	var pc_coord: Vector2i = ConvertCoord.get_coord(pc)
	var current_cart: Sprite2D = SpriteState.get_actor_by_coord(pc_coord)
	var find_cart: Sprite2D
	var find_coord: Vector2i

	find_cart = LinkedList.get_next_object(current_cart, state.linked_carts)
	if find_cart == pc:
		find_cart = LinkedList.get_next_object(
				find_cart, state.linked_carts
		)
	find_coord = ConvertCoord.get_coord(find_cart)
	SpriteState.move_sprite(pc, find_coord)


static func examine_previous_cart(pc: Sprite2D, state: LinkedCartState) -> void:
	var pc_coord: Vector2i = ConvertCoord.get_coord(pc)
	var current_cart: Sprite2D = SpriteState.get_actor_by_coord(pc_coord)
	var find_cart: Sprite2D
	var find_coord: Vector2i

	find_cart = LinkedList.get_previous_object(
			current_cart, state.linked_carts
	)
	if find_cart == pc:
		find_cart = LinkedList.get_previous_object(
				find_cart, state.linked_carts
		)
	find_coord = ConvertCoord.get_coord(find_cart)
	SpriteState.move_sprite(pc, find_coord)


static func get_extend_text(state: LinkedCartState) -> String:
	if state.add_cart_counter > 0:
		return EXTEND_TEMPLATE % state.add_cart_counter
	return ""


# This function should only be called in examine mode, which implies that there
# is a cart sprite under PC.
static func get_examine_text(pc: Sprite2D, state: LinkedCartState) -> String:
	return _get_cart_state_text(
			ConvertCoord.get_coord(pc), EXAMINE_TEMPLATE, state
	)


static func get_first_item_text(pc: Sprite2D, state: LinkedCartState) -> String:
	var cart: Sprite2D = get_first_item(pc, state)
	var coord: Vector2i

	if cart == null:
		return ""
	coord = ConvertCoord.get_coord(cart)
	return _get_cart_state_text(coord, FIRST_ITEM_TEMPLATE, state)


static func get_last_slot_text(pc: Sprite2D, state: LinkedCartState) -> String:
	var cart: Sprite2D = get_last_slot(pc, state)
	var coord: Vector2i

	if cart == null:
		return NO_LAST_SLOT
	coord = ConvertCoord.get_coord(cart)
	return _get_cart_state_text(coord, LAST_SLOT_TEMPLATE, state)


static func is_safe_load_amount_percent(
		check_type: int, safe_percent: float, ref_DataHub: DataHub
) -> bool:
	var pc: Sprite2D = ref_DataHub.pc
	var linked: LinkedCartState = ref_DataHub.linked_cart_state

	var cart: Sprite2D = get_last_slot(pc, linked)
	var current_load: int
	var count: int
	var max_load: int

	match check_type:
		SAFE_LOAD.FULL_LINE:
			current_load = get_full_load_amount(pc, linked)
			count = count_cart(linked)
		SAFE_LOAD.LAST_SLOT:
			if cart == null:
				return false
			current_load = get_state(cart, linked).load_amount
			count = 1
		_:
			return false
	max_load = floor(GameData.MAX_LOAD_PER_CART * count * safe_percent)
	return current_load < max_load


static func _get_cart_state_text(
		coord: Vector2i, text_template: String, state: LinkedCartState
) -> String:
	var cart: Sprite2D = SpriteState.get_actor_by_coord(coord)
	var cart_state: CartState = get_state(cart, state)
	var load_amount: int

	if cart_state == null:
		push_error("Cart state not found: [%d, %d]"
				% [coord.x, coord.y]
		)
		return ""
	elif cart_state.is_detached:
		return DETACHED
	elif cart_state.is_full:
		return FULL

	load_amount = int(
			cart_state.load_amount
			* PERCENT
			/ GameData.MAX_LOAD_PER_CART
	)
	return text_template % [
			ITEM_TO_STRING.get(cart_state.item_tag, "-"),
			load_amount,
	]


# Move carts from the first one (inclusive) to the last one (exclusive).
static func _move_cart(
		first_cart: Sprite2D, last_cart: Sprite2D,
		first_coord: Vector2i, state: LinkedCartState
) -> void:
	var next_cart: Sprite2D = first_cart
	var target_coord: Vector2i = first_coord
	var save_coord: Vector2i

	while true:
			# 1/2: Update coord for the next cart.
			save_coord = ConvertCoord.get_coord(next_cart)
			# Move current cart.
			SpriteState.move_sprite(next_cart, target_coord)
			# 2/2: Update coord for the next cart.
			next_cart = LinkedList.get_next_object(
					next_cart, state.linked_carts
			)
			target_coord = save_coord
			# End loop when reaching the last cart.
			if next_cart == last_cart:
				break


static func _add_cart_deferred(
		first_cart: Sprite2D, new_coord: Vector2i,
		state: LinkedCartState
) -> void:
	if state.add_cart_counter < 1:
		return

	var new_cart: Sprite2D = SpriteFactory.create_actor(
			SubTag.CART, new_coord, true
	).sprite

	LinkedList.insert_object(new_cart, first_cart, state.linked_carts)
	state.cart_states[new_cart.get_instance_id()] = CartState.new(new_cart)
	state.add_cart_counter -= 1


static func _remove_cart(
		first_cart: Sprite2D, remove_cart: Sprite2D,
		state: LinkedCartState
) -> void:
	var remove_id: int = remove_cart.get_instance_id()
	var remove_coord: Vector2i = ConvertCoord.get_coord(remove_cart)
	var next_cart: Sprite2D = LinkedList.get_next_object(
			remove_cart, state.linked_carts
	)

	LinkedList.remove_object(remove_cart, state.linked_carts)
	state.cart_states.erase(remove_id)
	SpriteFactory.remove_sprite(remove_cart)

	# Note that `state.linked_carts` is cyclic.
	# first_cart - ... - remove_cart - next_cart - ... - [first_cart]
	if next_cart != first_cart:
		_move_cart(next_cart, first_cart, remove_coord, state)

