class_name PcHitActor


static func handle_input(
		actor: Sprite2D, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber, ref_SignalHub: SignalHub,
		ref_Schedule: Schedule
) -> void:
	var actor_state: ActorState = ref_DataHub.get_actor_state(actor)
	var player_win: bool
	var count_servant: int = (
			ref_DataHub.count_servant + ref_DataHub.count_idler
	)
	var env_cooldown: int = (
			count_servant * GameData.RAW_FILE_ADD_COOLDOWN_SERVANT
	)
	var first_item_tag: StringName = _get_first_item_tag(ref_DataHub)

	match SpriteState.get_sub_tag(actor):
		SubTag.SALARY:
			player_win = ref_DataHub.delivery < 1
			if not _handle_salary(ref_DataHub, player_win):
				return

		SubTag.GARAGE:
			if not _handle_garage(ref_DataHub):
				return

		SubTag.STATION:
			if not _handle_station(ref_DataHub):
				return

		SubTag.SERVANT:
			_handle_servant(
					actor, actor_state, ref_DataHub,
					ref_RandomNumber
			)

		SubTag.OFFICER:
			if not _handle_officer(
					actor_state, ref_DataHub,
					ref_RandomNumber
			):
				return

		SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA, \
				SubTag.FIELD_REPORT:
			if not _handle_raw_file(
					actor, actor_state, env_cooldown,
					ref_DataHub, ref_RandomNumber
			):
				return

		SubTag.CLERK:
			if not _handle_clerk(
					actor_state, first_item_tag, ref_DataHub
			):
				return

		SubTag.PHONE:
			HandlePhone.answer_call(actor, ref_DataHub)

		SubTag.SHELF:
			if not _handle_shelf(
					actor_state, first_item_tag,
					ref_DataHub, ref_RandomNumber
			):
				return

		SubTag.EMPTY_CART:
			_load_cart(actor, ref_DataHub)

		_:
			return

	if player_win:
		ref_SignalHub.game_over.emit(true)
	else:
		ref_Schedule.start_next_turn()


static func can_load_servant(ref_DataHub: DataHub) -> bool:
	if (
			Cart.count_cart(ref_DataHub.linked_cart_state)
			<= GameData.CART_LENGTH_SHORT
	):
		return false

	var sprite: Sprite2D = Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	return sprite != null


static func can_load_tmp_file(
		actor_state: ActorState, ref_DataHub: DataHub
) -> bool:
	if not HandleShelf.can_send_tmp_file(actor_state):
		return false

	var cart: Sprite2D = Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	return cart != null


static func can_load_document(ref_DataHub: DataHub) -> bool:
	return Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	) != null


static func can_load_raw_file(actor: Sprite2D, ref_DataHub: DataHub) -> bool:
	if not HandleRawFile.can_send_raw_file(
			ref_DataHub.get_actor_state(actor)
	):
		return false
	elif (
			actor.is_in_group(SubTag.ENCYCLOPEDIA)
			and (not _is_long_cart(ref_DataHub))
	):
		return false

	var cart: Sprite2D = Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	return cart != null


static func can_unload_document(ref_DataHub: DataHub) -> bool:
	return _can_unload_archive(ref_DataHub, SubTag.DOCUMENT)


static func _can_get_cash(ref_DataHub: DataHub) -> bool:
	return ref_DataHub.account > 0


static func _get_cash(ref_DataHub: DataHub) -> void:
	ref_DataHub.cash += ref_DataHub.account
	ref_DataHub.account = 0


static func _can_use_garage(ref_DataHub: DataHub) -> bool:
	if ref_DataHub.delivery < 1:
		return false
	elif ref_DataHub.cash <= GameData.MIN_PAYMENT:
		return false
	return true


static func _use_garage(ref_DataHub: DataHub) -> void:
	Cart.add_cart(GameData.ADD_CART, ref_DataHub.linked_cart_state)
	ref_DataHub.cash -= GameData.PAYMENT_GARAGE


static func _can_clean_cart(ref_DataHub: DataHub) -> bool:
	return ref_DataHub.cash > GameData.MIN_PAYMENT


static func _clean_cart(ref_DataHub: DataHub) -> bool:
	if Cart.clean_cart(ref_DataHub.pc, ref_DataHub.linked_cart_state):
		ref_DataHub.cash -= GameData.PAYMENT_CLEAN
		return true
	return false


static func _push_servant(actor: Sprite2D, ref_DataHub: DataHub) -> void:
	var actor_coord: Vector2i = ConvertCoord.get_coord(actor)
	var actor_state: ServantState = ref_DataHub.get_actor_state(actor)
	var pc_coord: Vector2i = ref_DataHub.pc_coord
	var new_actor_coord: Vector2i
	var trap: Sprite2D
	var remove_actor: bool = true

	if (
			Cart.count_cart(ref_DataHub.linked_cart_state)
			<= GameData.CART_LENGTH_SHORT
	):
		ref_DataHub.delay = 0
	else:
		ref_DataHub.delay = PcHitTrap.get_delay_duration()

	new_actor_coord = ConvertCoord.get_mirror_coord(pc_coord, actor_coord)
	if _is_valid_coord(new_actor_coord):
		trap = SpriteState.get_trap_by_coord(new_actor_coord)
		if trap != null:
			SpriteFactory.remove_sprite(trap)
		if (trap == null) and (not actor_state.is_active):
			remove_actor = false
			SpriteState.move_sprite(actor, new_actor_coord)
	_move_cart(actor, remove_actor, actor_coord, ref_DataHub)
	if ref_DataHub.turn_counter % GameData.ADD_TRASH_INTERVAL == 0:
		Cart.add_trash(
				ref_DataHub.pc, ref_DataHub.linked_cart_state,
				NodeHub.ref_RandomNumber
		)
	#Cart.clean_short_cart(
	#		ref_DataHub.pc, ref_DataHub.linked_cart_state,
	#		GameData.CLEAN_SERVANT
	#)


static func _is_valid_coord(coord: Vector2i) -> bool:
	return (
			DungeonSize.is_in_dungeon(coord)
			and (not SpriteState.has_building_at_coord(coord))
			and (not SpriteState.has_actor_at_coord(coord))
	)


static func _can_unload_report(ref_DataHub: DataHub) -> bool:
	return _can_unload_archive(ref_DataHub, SubTag.FIELD_REPORT)


static func _can_unload_archive(
		ref_DataHub: DataHub, sub_tag: StringName
) -> bool:
	var cart_sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState

	if cart_sprite == null:
		return false

	cart_state = Cart.get_state(cart_sprite, ref_DataHub.linked_cart_state)
	return cart_state.item_tag == sub_tag


static func _unload_document(ref_DataHub: DataHub) -> void:
	_unload_item(ref_DataHub)

	# PC can still unload document after reaching the final goal (deliver 5
	# documents), but has no profit or penalty in return.
	if ref_DataHub.delivery > 0:
		ref_DataHub.account += GameData.INCOME_DOCUMENT
		ref_DataHub.delivery -= 1

		if ref_DataHub.incoming_call > GameData.MAX_MISSED_CALL:
			ref_DataHub.account -= GameData.MISSED_CALL_PENALTY


static func _unload_item(ref_DataHub: DataHub) -> void:
	var cart_sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState = Cart.get_state(
			cart_sprite, ref_DataHub.linked_cart_state
	)
	cart_state.item_tag = SubTag.CART


static func _load_raw_file(
		actor_state: ActorState, ref_DataHub: DataHub
) -> void:
	var cart_sprite: Sprite2D = Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState = Cart.get_state(
			cart_sprite, ref_DataHub.linked_cart_state
	)
	cart_state.item_tag = actor_state.sub_tag


static func _load_tmp_file(
		actor_state: ActorState, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber
) -> void:
	var cart_sprite: Sprite2D = Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState = Cart.get_state(
			cart_sprite, ref_DataHub.linked_cart_state
	)

	cart_state.item_tag = actor_state.item_tag
	Cart.add_trash(
			ref_DataHub.pc, ref_DataHub.linked_cart_state,
			ref_RandomNumber
	)


static func _load_document(ref_DataHub: DataHub) -> void:
	var sprite: Sprite2D =	Cart.get_last_slot(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var state: CartState = Cart.get_state(
			sprite, ref_DataHub.linked_cart_state
	)
	state.item_tag = SubTag.DOCUMENT


static func _can_unload_raw_file(ref_DataHub: DataHub) -> bool:
	var sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var state: CartState

	if sprite == null:
		return false

	state = Cart.get_state(sprite, ref_DataHub.linked_cart_state)
	return (
			(state.item_tag != SubTag.DOCUMENT)
			and (state.item_tag != SubTag.FIELD_REPORT)
			and (state.item_tag != SubTag.SERVANT)
	)


static func _can_unload_tmp_file(ref_DataHub: DataHub) -> bool:
	return _can_unload_raw_file(ref_DataHub)


static func _unload_tmp_file(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	_unload_item(ref_DataHub)
	Cart.add_trash(
			ref_DataHub.pc, ref_DataHub.linked_cart_state,
			ref_RandomNumber
	)


static func _get_first_item_tag(ref_DataHub: DataHub) -> StringName:
	var sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var state: CartState

	if sprite == null:
		return SubTag.CART
	state = Cart.get_state(sprite, ref_DataHub.linked_cart_state)
	return state.item_tag


static func _load_servant(
		actor: Sprite2D, actor_state: ActorState, ref_DataHub: DataHub
) -> void:
	var sprite: Sprite2D
	var state: CartState

	if not actor_state.is_active:
		sprite = Cart.get_last_slot(
				ref_DataHub.pc, ref_DataHub.linked_cart_state
		)
		state = Cart.get_state(
				sprite, ref_DataHub.linked_cart_state
		)
		state.item_tag = SubTag.SERVANT

	_move_cart(actor, true, ConvertCoord.get_coord(actor), ref_DataHub)


static func _remove_all_servant(ref_DataHub: DataHub) -> bool:
	return Cart.remove_all_item(
			SubTag.SERVANT, ref_DataHub.pc,
			ref_DataHub.linked_cart_state
	)


static func _can_unload_servant(actor: Sprite2D, ref_DataHub: DataHub) -> bool:
	var cart_sprite: Sprite2D = Cart.get_first_item(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)
	var cart_state: CartState

	if cart_sprite == null:
		return false

	cart_state = Cart.get_state(cart_sprite, ref_DataHub.linked_cart_state)
	if cart_state.item_tag != SubTag.SERVANT:
		return false

	if actor.is_in_group(SubTag.ENCYCLOPEDIA):
		return _is_long_cart(ref_DataHub)
	return true


static func _is_long_cart(ref_DataHub: DataHub) -> bool:
	return (
			Cart.count_cart(ref_DataHub.linked_cart_state)
			> GameData.CART_LENGTH_LONG
	)


static func _load_cart(actor: Sprite2D, ref_DataHub: DataHub) -> void:
	Cart.add_cart(
			GameData.ADD_EMPTY_CART_LENGTH,
			ref_DataHub.linked_cart_state
	)
	_move_cart(actor, true, ConvertCoord.get_coord(actor), ref_DataHub)


static func _move_cart(
		actor: Sprite2D, remove_actor: bool, coord: Vector2i,
		ref_DataHub: DataHub
) -> void:
	if remove_actor:
		SpriteFactory.remove_sprite(actor)
	Cart.pull_cart(
			ref_DataHub.pc, coord, ref_DataHub.linked_cart_state
	)


static func _handle_salary(ref_DataHub: DataHub, is_win: bool) -> bool:
	if _can_get_cash(ref_DataHub):
		_get_cash(ref_DataHub)
		return true
	elif is_win:
		return true
	return false


static func _handle_garage(ref_DataHub: DataHub) -> bool:
	if _can_use_garage(ref_DataHub):
		_use_garage(ref_DataHub)
		return true
	return false


static func _handle_station(ref_DataHub: DataHub) -> bool:
	if _can_clean_cart(ref_DataHub) and _clean_cart(ref_DataHub):
		return true
	return false


static func _handle_servant(
		actor: Sprite2D, actor_state: ActorState, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber
) -> void:
	if can_load_servant(ref_DataHub):
		_load_servant(actor, actor_state, ref_DataHub)
	else:
		HandleRawFile.reduce_cooldown(
				ref_DataHub.raw_file_states,
				ref_RandomNumber
		)
		#HandleClerk.reduce_progress(ref_DataHub, ref_RandomNumber)
		HandleServant.reset_idle_duration(actor_state)
		# Order matters. The Servant may be removed by _push_servant().
		_push_servant(actor, ref_DataHub)


static func _handle_officer(
		actor_state: ActorState, ref_DataHub: DataHub,
		ref_RandomNumber: RandomNumber
) -> bool:
	if _remove_all_servant(ref_DataHub):
		return true
	elif (
			HandleOfficer.can_receive_archive(actor_state)
			and _can_unload_report(ref_DataHub)
	):
		_unload_item(ref_DataHub)
		HandleOfficer.set_active(
				ref_DataHub.officer_states,
				ref_DataHub.officer_records,
				ref_RandomNumber
		)
		return true
	elif (
			HandleOfficer.can_receive_archive(actor_state)
			and can_unload_document(ref_DataHub)
	):
		_unload_document(ref_DataHub)
		# NOTE: Uncomment this line if the game becomes too hard.
		#HandleRawFile.reset_cooldown(ref_DataHub.raw_file_states)
		HandleOfficer.set_active(
				ref_DataHub.officer_states,
				ref_DataHub.officer_records, ref_RandomNumber
		)
		GameProgress.update_challenge_level(ref_DataHub)
		GameProgress.update_raw_file(ref_DataHub, ref_RandomNumber)
		GameProgress.update_service(ref_DataHub, ref_RandomNumber)
		return true
	return false


static func _handle_raw_file(
		actor: Sprite2D, actor_state: ActorState, env_cooldown: int,
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> bool:
	if can_load_raw_file(actor, ref_DataHub):
		_load_raw_file(actor_state, ref_DataHub)
		HandleRawFile.send_raw_file(
				actor_state, env_cooldown,
				ref_RandomNumber
		)
		return true
	elif (
			_can_unload_servant(actor, ref_DataHub)
			and HandleRawFile.can_receive_servant(actor_state)
	):
		_unload_item(ref_DataHub)
		HandleRawFile.receive_servant(actor_state)
		return true
	return false


static func _handle_clerk(
		actor_state: ActorState, first_item_tag: StringName,
		ref_DataHub: DataHub
) -> bool:
	if (
			can_load_document(ref_DataHub)
			and HandleClerk.can_send_document(actor_state)
	):
		_load_document(ref_DataHub)
		HandleClerk.send_document(actor_state)
		return true
	elif (
			_can_unload_raw_file(ref_DataHub)
			and HandleClerk.can_receive_raw_file(
					actor_state, first_item_tag
			)
	):
		_unload_item(ref_DataHub)
		HandleClerk.receive_raw_file(actor_state, first_item_tag)
		return true
	return false


static func _handle_shelf(
		actor_state: ActorState, first_item_tag: StringName,
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> bool:
	if can_load_tmp_file(actor_state, ref_DataHub):
		_load_tmp_file(actor_state, ref_DataHub, ref_RandomNumber)
		HandleShelf.send_tmp_file(actor_state)
		return true
	elif (
			_can_unload_tmp_file(ref_DataHub)
			and HandleShelf.can_receive_tmp_file(actor_state)
	):
		_unload_tmp_file(ref_DataHub, ref_RandomNumber)
		HandleShelf.receive_tmp_file(actor_state, first_item_tag)
		return true
	return false

