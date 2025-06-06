class_name HandleGameplayInput


const INVALID_COORD: Vector2i = Vector2i(-1, -1)
const MESSAGE_TEMPLATE: String = "%s: %s"

const FAST_STEP: int = 5
const FAST_MOVE_LEFT: Vector2i = Vector2i(-FAST_STEP, 0)
const FAST_MOVE_RIGHT: Vector2i = Vector2i(FAST_STEP, 0)
const FAST_MOVE_UP: Vector2i = Vector2i(0, -FAST_STEP)
const FAST_MOVE_DOWN: Vector2i = Vector2i(0, FAST_STEP)

const BUFFER_SUB_TAG: Dictionary = {
	SubTag.SERVANT: true,
	SubTag.CLERK: true,
	SubTag.OFFICER: true,
	SubTag.ATLAS: true,
	SubTag.BOOK: true,
	SubTag.CUP: true,
	SubTag.ENCYCLOPEDIA: true,
	SubTag.FIELD_REPORT: true,
	SubTag.SHELF: true,
	SubTag.GARAGE: true,
	SubTag.STATION: true,
}


class BufferInputData:
	var direction: Vector2i
	var input_coord: Vector2i
	var buffer_coord: Vector2i = INVALID_COORD


static func is_normal_input(
		input_tag: StringName, data: BufferInputData
) -> bool:
	var dh := NodeHub.ref_DataHub
	var linked := dh.linked_cart_state

	match input_tag:
		InputTag.SWITCH_EXAMINE:
			if not Cart.can_enter_examine_mode(linked):
				return true
			dh.set_game_mode(GameData.EXAMINE_MODE)
			PcSwitchMode.examine_mode(true, dh)
			return false

		InputTag.SWITCH_HELP:
			dh.set_game_mode(GameData.HELP_MODE)
			PcSwitchMode.help_mode(true)
			return false

		InputTag.MOVE_LEFT:
			_move_normal(Vector2i.LEFT, linked, data)
			return true
		InputTag.MOVE_RIGHT:
			_move_normal(Vector2i.RIGHT, linked, data)
			return true
		InputTag.MOVE_UP:
			_move_normal(Vector2i.UP, linked, data)
			return true
		InputTag.MOVE_DOWN:
			_move_normal(Vector2i.DOWN, linked, data)
			return true

		InputTag.WIZARD_1, InputTag.WIZARD_2, \
				InputTag.WIZARD_3, InputTag.WIZARD_4, \
				InputTag.WIZARD_5, InputTag.WIZARD_6, \
				InputTag.WIZARD_7, InputTag.WIZARD_8, \
				InputTag.WIZARD_9, InputTag.WIZARD_0:
			WizardMode.handle_input(input_tag)
			return false

	return true


static func is_examine_input(
		input_tag: StringName, data: BufferInputData
) -> bool:
	var dh := NodeHub.ref_DataHub
	var linked := dh.linked_cart_state

	match input_tag:
		InputTag.SWITCH_EXAMINE, InputTag.EXIT_ALT_MODE:
			# Reset buffer state when leaving Examine Mode.
			_set_buffer_state(data, GameData.WARN.NO_ALERT, false)
			dh.set_game_mode(GameData.NORMAL_MODE)
			PcSwitchMode.examine_mode(false, dh)

		InputTag.MOVE_UP:
			Cart.examine_first_cart(dh.pc, linked)
		InputTag.MOVE_DOWN:
			Cart.examine_last_cart(dh.pc, linked)
		InputTag.MOVE_LEFT:
			Cart.examine_previous_cart(dh.pc, linked)
		InputTag.MOVE_RIGHT, InputTag.EXAMINE_NEXT_CART:
			Cart.examine_next_cart(dh.pc, linked)

		_:
			return true

	return false


static func show_all_sprite() -> void:
	if not NodeHub.ref_DataHub.show_all_sprite:
		return
	NodeHub.ref_DataHub.show_all_sprite = false
	for i: Sprite2D in NodeHub.ref_SpriteRoot.get_children():
		VisualEffect.set_visibility(i, true)


static func is_help_input(input_tag: StringName) -> bool:
	var dh := NodeHub.ref_DataHub

	match input_tag:
		InputTag.SWITCH_HELP, InputTag.EXIT_ALT_MODE:
			dh.set_game_mode(GameData.NORMAL_MODE)
			PcSwitchMode.help_mode(false)
			return true

		InputTag.FAST_MOVE_LEFT:
			_move_help(FAST_MOVE_LEFT)
			return true
		InputTag.FAST_MOVE_RIGHT:
			_move_help(FAST_MOVE_RIGHT)
			return true
		InputTag.FAST_MOVE_UP:
			_move_help(FAST_MOVE_UP)
			return true
		InputTag.FAST_MOVE_DOWN:
			_move_help(FAST_MOVE_DOWN)
			return true

		InputTag.MOVE_LEFT:
			_move_help(Vector2i.LEFT)
			return true
		InputTag.MOVE_RIGHT:
			_move_help(Vector2i.RIGHT)
			return true
		InputTag.MOVE_UP:
			_move_help(Vector2i.UP)
			return true
		InputTag.MOVE_DOWN:
			_move_help(Vector2i.DOWN)
			return true

	return false


static func _move_normal(
		direction: Vector2i, state: LinkedCartState,
		data: BufferInputData
) -> void:
	var coord: Vector2i = (
			ConvertCoord.get_coord(NodeHub.ref_DataHub.pc)
			+ direction
	)
	var sprite: Sprite2D
	var sub_tag: StringName

	data.direction = direction
	data.input_coord = coord

	if not DungeonSize.is_in_dungeon(coord):
		return

	elif _try_buffer_input(data):
		return

	elif SpriteState.has_actor_at_coord(coord):
		sprite = SpriteState.get_actor_by_coord(coord)
		sub_tag = SpriteState.get_sub_tag(sprite)
		PcHitActor.handle_input(
				sprite, NodeHub.ref_DataHub,
				NodeHub.ref_RandomNumber, NodeHub.ref_SignalHub,
				NodeHub.ref_Schedule
		)
		return

	elif SpriteState.has_trap_at_coord(coord):
		sprite = SpriteState.get_trap_by_coord(coord)
		sub_tag = SpriteState.get_sub_tag(sprite)
		if sub_tag != SubTag.TRASH:
			return
		PcHitTrap.handle_input(
				sprite, NodeHub.ref_DataHub,
				NodeHub.ref_RandomNumber, NodeHub.ref_Schedule
		)
		return

	elif SpriteState.has_building_at_coord(coord):
		sprite = SpriteState.get_building_by_coord(coord)
		if not sprite.is_in_group(SubTag.DOOR):
			return

	Cart.pull_cart(NodeHub.ref_DataHub.pc, coord, state)
	Cart.add_trash(NodeHub.ref_DataHub.pc, state, NodeHub.ref_RandomNumber)
	NodeHub.ref_Schedule.start_next_turn()


static func _try_buffer_input(data: BufferInputData) -> bool:
	var is_same_input: bool

	# There is a buffer input.
	if data.buffer_coord != INVALID_COORD:
		is_same_input = (data.buffer_coord == data.input_coord)
		# Always reset buffer state.
		_set_buffer_state(data, GameData.WARN.NO_ALERT, false)
		# The same input key is pressed the second time. Pass the key to
		# following code outside `_try_buffer_input()`.
		if is_same_input:
			return false
		# Another input key is pressed. Check whether to buffer the key
		# normally.
		else:
			pass

	var actor: Sprite2D
	var sub_tag: StringName
	var has_actor: bool = false

	# It's safe to interact with a Building.
	if SpriteState.has_building_at_coord(data.input_coord):
		return false
	# Try to buffer an input when interacting with a specific actor.
	actor = SpriteState.get_actor_by_coord(data.input_coord)
	if actor != null:
		sub_tag = SpriteState.get_sub_tag(actor)
		if not BUFFER_SUB_TAG.has(sub_tag):
			return false
		has_actor = true

	var is_buffered: bool = false
	var is_safe_last: bool = Cart.is_safe_load_amount_percent(
			Cart.SAFE_LOAD.LAST_SLOT,
			GameData.SAFE_LOAD_AMOUNT_PERCENT_1,
			NodeHub.ref_DataHub
	)
	var is_safe_full: bool = Cart.is_safe_load_amount_percent(
			Cart.SAFE_LOAD.FULL_LINE,
			GameData.SAFE_LOAD_AMOUNT_PERCENT_2,
			NodeHub.ref_DataHub
	)
	var is_all_safe: bool = is_safe_last and is_safe_full
	var warn_type: int

	if not has_actor:
		# Warn player when he might be trapped.
		if Checkmate.is_trapped(data.input_coord):
			is_buffered = true
			warn_type = GameData.WARN.TRAPPED
		# Warn player when moving into a Trash and the overall load
		# amout is more than 60% (GameData.SAFE_LOAD_AMOUNT_PERCENT_2).
		elif _handle_trash(data.input_coord, is_safe_full):
			is_buffered = true
			warn_type = GameData.WARN.SLOW
		else:
			is_buffered = false
		if is_buffered:
			_set_buffer_state(data, warn_type, true)
			return true
		return false

	var state: ActorState = NodeHub.ref_DataHub.get_actor_state(actor)

	match sub_tag:
		# Warn player when a Servant being pushed might disappear, or
		# the Servant is pushed by a long line of Carts.
		SubTag.SERVANT:
			is_buffered = _handle_servant(data.input_coord)
			warn_type = GameData.WARN.PUSH

		# [Achievement] Warn player if his Cash is less than 1 after the
		# service; or there are only 3 (GameData.CART_LENGTH_SHORT)
		# Carts right now.
		SubTag.GARAGE:
			is_buffered = (
					_handle_cost(GameData.PAYMENT_GARAGE)
					or _handle_garage()
			)
			warn_type = GameData.WARN.ADD_CART

		# Warn player if his Cash is less than 1 after the service.
		SubTag.STATION:
			is_buffered = (
					_handle_cost(GameData.PAYMENT_CLEAN)
					or _handle_station()
			)
			warn_type = GameData.WARN.CLEAN

		# [Achievement] Warn player when loading a Raw File.
		SubTag.SHELF:
			is_buffered = _handle_shelf(state)
			warn_type = GameData.WARN.SHELF

		# Warn player when loading a Document and ..
		# 1. the last slot is more than 40%
		# (GameData.SAFE_LOAD_AMOUNT_PERCENT_1) full;
		# 2. or the overall load amount is more than 60%
		# (GameData.SAFE_LOAD_AMOUNT_PERCENT_2);
		# 3. or there is more than 1 (GameData.MAX_MISSED_CALL) Phone
		# calls.
		SubTag.CLERK:
			is_buffered = _handle_clerk(state, is_all_safe)
			warn_type = GameData.WARN.DOCUMENT

		# Warn player when loading a Raw File and ...
		# 1. the last slot is more than 40%
		# (GameData.SAFE_LOAD_AMOUNT_PERCENT_1) full;
		# 2. or the overall load amount is more than 60%
		# (GameData.SAFE_LOAD_AMOUNT_PERCENT_2).
		SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
			is_buffered = _handle_raw_file(actor, is_all_safe)
			warn_type = GameData.WARN.LOAD

		# [Achievement] Warn player when loading a Field Report
		# regardless of load amount.
		SubTag.FIELD_REPORT:
			is_buffered = _handle_raw_file(actor, false)
			warn_type = GameData.WARN.REPORT

		# Warn player when unloading a Document and there is more than
		# 1 (GameData.MAX_MISSED_CALL) Phone calls.
		SubTag.OFFICER:
			is_buffered = _handle_officer(state)
			warn_type = GameData.WARN.DOCUMENT

	if is_buffered:
		_set_buffer_state(data, warn_type, true)
		return true
	return false


static func _set_buffer_state(
		data: BufferInputData, warn_type: int, has_new_input: bool,
) -> void:
	var visual_tag: StringName
	var message: String
	var str_dir: String

	if has_new_input:
		visual_tag = VisualTag.VECTOR_TO_TAG.get(
				data.direction, VisualTag.DEFAULT
		)
		data.buffer_coord = data.input_coord

		message = GameData.WARN_TO_STRING.get(warn_type, "")
		str_dir = ConvertCoord.VECTOR_TO_STRING.get(data.direction, "")
		message = MESSAGE_TEMPLATE % [str_dir, message]

		NodeHub.ref_DataHub.set_sidebar_message(message)
		NodeHub.ref_SignalHub.ui_force_updated.emit()
		NodeHub.ref_DataHub.set_sidebar_message("")

	else:
		visual_tag = VisualTag.DEFAULT
		data.buffer_coord = INVALID_COORD

	VisualEffect.switch_sprite(NodeHub.ref_DataHub.pc, visual_tag)


static func _handle_servant(coord: Vector2i) -> bool:
	var mirror_coord: Vector2i
	var top_sprite: Sprite2D

	if PcHitActor.can_load_servant(NodeHub.ref_DataHub):
		return false
	elif (
			Cart.count_cart(NodeHub.ref_DataHub.linked_cart_state)
			> GameData.CART_LENGTH_SHORT
	):
		return true

	mirror_coord = ConvertCoord.get_mirror_coord(
			NodeHub.ref_DataHub.pc_coord, coord
	)
	if not DungeonSize.is_in_dungeon(mirror_coord):
		return true

	top_sprite = SpriteState.get_top_sprite_by_coord(mirror_coord)
	if top_sprite == null:
		return false
	elif (
			top_sprite.is_in_group(MainTag.BUILDING)
			or top_sprite.is_in_group(MainTag.ACTOR)
			or top_sprite.is_in_group(MainTag.TRAP)
	):
		return true
	return false


static func _handle_cost(cost: int) -> bool:
	if (
			(NodeHub.ref_DataHub.cash > 0)
			and (NodeHub.ref_DataHub.cash <= cost)
	):
		return true
	return false


static func _handle_garage() -> bool:
	if NodeHub.ref_DataHub.cash < 1:
		return false
	elif (
		Cart.count_cart(NodeHub.ref_DataHub.linked_cart_state)
		> GameData.CART_LENGTH_SHORT
	):
		return false
	return true


static func _handle_station() -> bool:
	if NodeHub.ref_DataHub.cash < 1:
		return false

	var item_tags: Array = Cart.get_all_item_tag(
			NodeHub.ref_DataHub.pc,
			NodeHub.ref_DataHub.linked_cart_state
	)

	if item_tags.size() <= GameData.CART_LENGTH_SHORT:
		return false

	for i: int in range(0, item_tags.size()):
		if i <= GameData.CART_LENGTH_SHORT:
			continue
		elif item_tags[i] == SubTag.FULL:
			continue
		# This should not happen.
		elif item_tags[i] == SubTag.DETACHED:
			continue
		return false
	return true


static func _handle_shelf(actor_state: ActorState) -> bool:
	if PcHitActor.can_load_tmp_file(actor_state, NodeHub.ref_DataHub):
		return true
	return false


static func _handle_clerk(actor_state: ActorState, is_safe_load: bool) -> bool:
	if is_safe_load and (not _handle_phone_call()):
		return false
	elif not PcHitActor.can_load_document(NodeHub.ref_DataHub):
		return false
	elif not HandleClerk.can_send_document(actor_state):
		return false
	return true


static func _handle_raw_file(actor: Sprite2D, is_safe_load: bool) -> bool:
	if is_safe_load:
		return false
	elif not PcHitActor.can_load_raw_file(actor, NodeHub.ref_DataHub):
		return false
	return true


static func _handle_trash(coord: Vector2i, is_safe_load: bool) -> bool:
	var trap: Sprite2D = SpriteState.get_trap_by_coord(coord)

	if trap == null:
		return false
	elif not trap.is_in_group(SubTag.TRASH):
		return false
	elif is_safe_load:
		return false
	return true


static func _handle_officer(actor_state: ActorState) -> bool:
	var count_servant: int = Cart.count_item(
			SubTag.SERVANT, NodeHub.ref_DataHub.pc,
			NodeHub.ref_DataHub.linked_cart_state
	)

	if count_servant > 0:
		return false
	elif not _handle_phone_call():
		return false
	elif not HandleOfficer.can_receive_archive(actor_state):
		return false
	elif not PcHitActor.can_unload_document(NodeHub.ref_DataHub):
		return false
	return true


static func _handle_phone_call() -> bool:
	if NodeHub.ref_DataHub.incoming_call <= GameData.MAX_MISSED_CALL:
		return false
	return true


static func _move_help(direction: Vector2i) -> void:
	var dh := NodeHub.ref_DataHub

	var coord: Vector2i = (dh.pc_coord + direction)

	if not DungeonSize.is_in_dungeon(coord):
		coord.x = max(0, min(DungeonSize.MAX_X - 1, coord.x))
		coord.y = max(0, min(DungeonSize.MAX_Y - 1, coord.y))
	SpriteState.move_sprite(dh.pc, coord)

