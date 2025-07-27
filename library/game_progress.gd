class_name GameProgress


const MAX_RETRY: int = 10


static func update_world(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	_init_ground_coords(ref_DataHub, ref_RandomNumber)

	# Create Servants. This challenge is available throughout the game.
	_create_rand_sprite(
			MainTag.ACTOR, SubTag.SERVANT, ref_DataHub,
			ref_RandomNumber, MAX_RETRY
	)

	# Create Trashes.
	var servant_mod: int = 1

	if not GameData.LEVEL_TO_TRAP.has(ref_DataHub.challenge_level):
		push_error("Invalid challenge level: %d"
				% ref_DataHub.challenge_level
		)
	servant_mod = GameData.LEVEL_TO_TRAP[ref_DataHub.challenge_level]
	ref_DataHub.max_trap = (
			ref_DataHub.count_servant * servant_mod
			+ ref_DataHub.count_idler
	)
	_create_rand_sprite(
			MainTag.TRAP, SubTag.TRASH, ref_DataHub,
			ref_RandomNumber, MAX_RETRY
	)

	# Reduce Clerk progress.
	#if ref_DataHub.challenge_level >= GameData.MIN_LEAK_LEVEL:
	#	HandleClerk.reduce_progress(ref_DataHub, ref_RandomNumber)

	# Create Phones.
	# {cash: max_call}: {-1: 3, 0: 2, 1: 1, 2: 0, 3: -1, ...}
	ref_DataHub.max_call = GameData.DEFAULT_CALL - ref_DataHub.cash
	ref_DataHub.max_call = max(GameData.MIN_CALL, ref_DataHub.max_call)
	ref_DataHub.max_call = min(GameData.MAX_CALL, ref_DataHub.max_call)
	ref_DataHub.max_call = min(
			ref_DataHub.incoming_call + ref_DataHub.remaining_call,
			ref_DataHub.max_call
	)
	ref_DataHub.max_call -= ref_DataHub.incoming_call
	if _can_create_phone(ref_DataHub):
		_create_rand_phone(ref_DataHub, ref_RandomNumber)


static func update_turn_counter(ref_DataHub: DataHub) -> void:
	ref_DataHub.turn_counter += 1


static func update_challenge_level(ref_DataHub: DataHub) -> void:
	ref_DataHub.challenge_level += 1


static func update_raw_file(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	var sprites: Array = ref_DataHub.raw_file_sprites
	var states: Array = ref_DataHub.raw_file_states

	_swap_sprites(sprites, ref_RandomNumber)
	for i in states:
		i.reset_progress_bar_coord()
	for i in SpriteState.get_sprites_by_sub_tag(SubTag.PROGRESS_BAR):
		SpriteFactory.remove_sprite(i)


static func update_service(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	_swap_sprites(ref_DataHub.service_sprites, ref_RandomNumber)


static func update_remaining_call() -> void:
	NodeHub.ref_DataHub.remaining_call = GameData.INITIAL_REMAINING_CALL


static func _swap_sprites(
		sprites: Array, ref_RandomNumber: RandomNumber
) -> void:
	ArrayHelper.shuffle(sprites, ref_RandomNumber)
	for i in range(0, sprites.size() - 1):
		SpriteState.swap_sprite(sprites[i], sprites[i + 1])


static func _init_ground_coords(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	if not ref_DataHub.ground_coords.is_empty():
		return

	for x in range(0, DungeonSize.MAX_X):
		for y in range(0, DungeonSize.MAX_Y):
			_init_ground_xy(x, y, ref_DataHub)

	ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _init_phone_coords(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	if not ref_DataHub.phone_coords.is_empty():
		return

	for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(
			SubTag.PHONE_BOOTH
	):
		ref_DataHub.set_phone_coords(ConvertCoord.get_coord(i))
	ref_DataHub.phone_index = -1
	ArrayHelper.shuffle(ref_DataHub.phone_coords, ref_RandomNumber)


static func _create_rand_sprite(
		main_tag: StringName, sub_tag: StringName, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber, retry: int
) -> void:
	if retry < 1:
		return
	elif not _is_valid_turn(ref_DataHub.turn_counter, main_tag):
		return

	match main_tag:
		MainTag.ACTOR:
			if _has_max_actor(ref_DataHub):
				return
		MainTag.TRAP:
			if _has_max_trap(ref_DataHub):
				return
		_:
			return

	var coord: Vector2i = ref_DataHub.ground_coords[
			ref_DataHub.ground_index
	]
	var is_valid: bool = _is_valid_coord(
			coord, ref_DataHub.pc_coord, sub_tag
	)

	_update_ground_index(ref_DataHub, ref_RandomNumber)
	if not is_valid:
		_create_rand_sprite(
				main_tag, sub_tag, ref_DataHub,
				ref_RandomNumber, retry - 1
		)
		return

	match main_tag:
		MainTag.ACTOR:
			SpriteFactory.create_actor(sub_tag, coord, true)
		MainTag.TRAP:
			_create_trap(
					sub_tag, coord,
					ref_DataHub, ref_RandomNumber
			)


static func _create_rand_phone(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	var phone_coord: Vector2i
	var max_retry: int = MAX_RETRY

	_init_phone_coords(ref_DataHub, ref_RandomNumber)

	while (ref_DataHub.max_call > 0) and (max_retry > 0):
		max_retry -= 1
		_update_phone_index(ref_DataHub, ref_RandomNumber)
		phone_coord = ref_DataHub.phone_coords[ref_DataHub.phone_index]

		if SpriteState.has_actor_at_coord(phone_coord):
			continue
		elif not _is_valid_coord(
				phone_coord, ref_DataHub.pc_coord, SubTag.PHONE
		):
			continue
		SpriteFactory.create_actor(SubTag.PHONE, phone_coord, true)
		ref_DataHub.max_call -= 1
		ref_DataHub.remaining_call -= 1


static func _has_max_actor(ref_DataHub: DataHub) -> bool:
	var occupied_shelf: int = HandleShelf.count_occupied_shelf(
			ref_DataHub.shelf_states
	)
	var is_short_cart: bool = (
			Cart.count_cart(ref_DataHub.linked_cart_state)
			<= GameData.CART_LENGTH_SHORT
	)
	var shelf_add: int
	var max_servant: int

	if is_short_cart:
		shelf_add = GameData.SHELF_ADD_SERVANT_1 * occupied_shelf
	else:
		shelf_add = GameData.SHELF_ADD_SERVANT_2 * occupied_shelf

	max_servant = GameData.BASE_SERVANT \
			+ min(ref_DataHub.count_idler, shelf_add)

	var current_servant: int = ref_DataHub.count_servant
	var carry_servant: int = Cart.count_item(
			SubTag.SERVANT, ref_DataHub.pc,
			ref_DataHub.linked_cart_state
	)

	return current_servant + carry_servant >= max_servant


static func _is_invalid_sprite(sprite: Sprite2D) -> bool:
	var main_tag: StringName = SpriteState.get_main_tag(sprite)
	var sub_tag: StringName = SpriteState.get_sub_tag(sprite)

	if sub_tag == SubTag.INTERNAL_FLOOR:
		return true
	elif main_tag == MainTag.BUILDING:
		return true
	elif (main_tag == MainTag.ACTOR) and (sub_tag != SubTag.PC):
		return true
	return false


static func _is_valid_turn(turn_counter: int, main_tag: StringName) -> bool:
	var turn_interval: int

	match main_tag:
		MainTag.ACTOR:
			turn_interval = GameData.NEW_ACTOR_INTERVAL
		MainTag.TRAP:
			turn_interval = GameData.NEW_TRAP_INTERVAL
		_:
			return false
	return turn_counter % turn_interval == 0


static func _has_max_trap(ref_DataHub: DataHub) -> bool:
	return (
			ref_DataHub.count_trash + ref_DataHub.count_empty_cart
			>= ref_DataHub.max_trap
	)


static func _is_valid_coord(
		check_coord: Vector2i, pc_coord: Vector2i, sub_tag: StringName
) -> bool:
	if SpriteState.has_actor_at_coord(check_coord):
		return false
	elif SpriteState.has_trap_at_coord(check_coord):
		return false
	elif ConvertCoord.is_in_range(
			check_coord, pc_coord, GameData.MIN_DISTANCE_TO_PC
	):
		return false
	elif not ConvertCoord.is_in_range(
			check_coord, pc_coord, GameData.MAX_DISTANCE_TO_PC
	):
		return false

	var max_count: int

	match sub_tag:
		SubTag.TRASH:
			max_count = GameData.MAX_TRASH_PER_LINE
			return _is_valid_line(
					MainTag.TRAP, sub_tag,
					check_coord, max_count
			)
		SubTag.SERVANT:
			max_count = GameData.MAX_SERVANT_PER_LINE
			return _is_valid_line(
					MainTag.ACTOR, sub_tag,
					check_coord, max_count
			)
	return true


static func _update_ground_index(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	ref_DataHub.ground_index += 1
	if ref_DataHub.ground_index < ref_DataHub.ground_coords.size():
		return
	ref_DataHub.ground_index = 0
	ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _update_phone_index(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	ref_DataHub.phone_index += 1
	if ref_DataHub.phone_index < ref_DataHub.phone_coords.size():
		return
	ref_DataHub.phone_index = 0
	ArrayHelper.shuffle(ref_DataHub.phone_coords, ref_RandomNumber)


static func _has_document(ref_DataHub: DataHub) -> bool:
	var cart_sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState

	if cart_sprite == null:
		return false

	cart_state = Cart.get_state(
			cart_sprite, ref_DataHub.linked_cart_state
	)
	return cart_state.item_tag == SubTag.DOCUMENT


static func _can_create_empty_cart(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> bool:
	if (
			Cart.count_cart(ref_DataHub.linked_cart_state)
			<= GameData.CART_LENGTH_SHORT
	):
		return false
	elif Cart.is_safe_load_amount_percent(
			Cart.SAFE_LOAD.FULL_LINE,
			GameData.SAFE_LOAD_AMOUNT_PERCENT_3,
			ref_DataHub
	):
		return false
	return ref_RandomNumber.get_percent_chance(
			GameData.ADD_EMPTY_CART_CHANCE
	)


static func _can_create_phone(ref_DataHub: DataHub) -> bool:
	if ref_DataHub.max_call <= 0:
		return false
	elif _has_document(ref_DataHub):
		return false
	elif Cart.is_safe_load_amount_percent(
			Cart.SAFE_LOAD.FULL_LINE,
			GameData.SAFE_LOAD_AMOUNT_PERCENT_3,
			ref_DataHub
	):
		return false
	return true


static func _is_valid_line(
		main_tag: StringName, sub_tag: StringName,
		check_coord: Vector2i, max_count: int
) -> bool:
	var coord: Vector2i = Vector2i(0, 0)
	var count: int
	var sprite: Sprite2D

	count = 0
	for i: int in range(0, DungeonSize.MAX_X):
		coord.x = i
		coord.y = check_coord.y
		sprite = SpriteState.get_sprite_by_coord(main_tag, coord)
		if sprite == null:
			continue
		elif not sprite.is_in_group(sub_tag):
			continue
		count += 1
		if count >= max_count:
			return false

	count = 0
	for i: int in range(0, DungeonSize.MAX_Y):
		coord.x = check_coord.x
		coord.y = i
		sprite = SpriteState.get_sprite_by_coord(main_tag, coord)
		if sprite == null:
			continue
		elif not sprite.is_in_group(sub_tag):
			continue
		count += 1
		if count >= max_count:
			return false
	return true


static func _init_ground_xy(x: int, y: int, ref_DataHub: DataHub) -> void:
	var coord: Vector2i = Vector2i(x, y)
	var sprites: Array = SpriteState.get_sprites_by_coord(coord)

	for i: Sprite2D in sprites:
		if _is_invalid_sprite(i):
			return

	ref_DataHub.set_ground_coords(coord)


static func _create_trap(
		sub_tag: StringName, coord: Vector2i,
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	if _can_create_empty_cart(ref_DataHub, ref_RandomNumber):
		SpriteFactory.create_actor(SubTag.EMPTY_CART, coord, true)
	else:
		SpriteFactory.create_trap(sub_tag, coord, true)

