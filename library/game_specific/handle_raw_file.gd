class_name HandleRawFile


static func can_send_raw_file(state: RawFileState) -> bool:
	return state.cooldown < 1


static func send_raw_file(
		state: RawFileState, env_cooldown: int,
		ref_RandomNumber: RandomNumber
) -> void:
	var base_cooldown: int = ref_RandomNumber.get_int(
			GameData.RAW_FILE_MIN_BASE_COOLDOWN,
			GameData.RAW_FILE_MAX_BASE_COOLDOWN + 1)
	var send_cooldown: int = (
			state.send_counter * GameData.RAW_FILE_ADD_COOLDOWN_SEND
	)

	# Cooldown is set in PC's turn and is decreased by 1 at the start of an
	# NPC's turn.
	state.max_cooldown = base_cooldown + send_cooldown + env_cooldown
	state.cooldown = 1 + state.max_cooldown
	state.send_counter += 1
	# print("CD: %s, Counter: %s" % [state.cooldown, state.send_counter])


static func reset_cooldown(raw_file_states: Array) -> void:
	for i: RawFileState in raw_file_states:
		i.cooldown = 0
		i.send_counter -= GameData.RAW_FILE_SEND_COUNTER


static func update_cooldown(state: RawFileState) -> void:
	state.cooldown -= GameData.RAW_FILE_REDUCE_COOLDOWN_PASSIVE


static func reduce_cooldown(
		raw_file_states: Array, ref_RandomNumber: RandomNumber
) -> void:
	const CD_PUSH: int = GameData.RAW_FILE_REDUCE_COOLDOWN_PUSH_SERVANT

	var cooldown_percent: float
	var max_percent: float = GameData.RAW_FILE_REDUCE_COOLDOWN_MAX_PERCENT
	var min_percent: float = GameData.RAW_FILE_REDUCE_COOLDOWN_MIN_PERCENT
	var state: RawFileState = null

	ArrayHelper.shuffle(raw_file_states, ref_RandomNumber)
	for i: RawFileState in raw_file_states:
		# Skip usable Raw File nodes.
		if i.cooldown == 0:
			continue
		# Focus on nodes whose cooldowns are very high or very low.
		cooldown_percent = i.cooldown * 1.0 / i.max_cooldown
		if (
				(cooldown_percent >= max_percent)
				or (cooldown_percent <= min_percent)
		):
			i.cooldown -= CD_PUSH
			return
		# Otherwise, reduce a random node's cooldown.
		else:
			state = i
	if state != null:
		state.cooldown -= CD_PUSH


static func can_receive_servant(state: RawFileState) -> bool:
	return state.cooldown > 0


static func receive_servant(state: RawFileState) -> void:
	state.cooldown -= GameData.RAW_FILE_REDUCE_COOLDOWN_UNLOAD_SERVANT


static func switch_examine_mode(is_enter: bool, states: Array) -> void:
	for i: RawFileState in states:
		_switch_encyclopedia(is_enter, i)
		if not _switch_progress_bar(is_enter, i):
			continue


static func _switch_encyclopedia(is_enter: bool, state: RawFileState) -> void:
	if state.sub_tag != SubTag.ENCYCLOPEDIA:
		return

	var visual_tag: StringName = VisualTag.DEFAULT
	var is_short_cart: bool = (
			Cart.count_cart(NodeHub.ref_DataHub.linked_cart_state)
			<= GameData.CART_LENGTH_LONG
	)

	if is_enter:
		if is_short_cart:
			visual_tag = VisualTag.PASSIVE
	VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _switch_progress_bar(is_enter: bool, state: RawFileState) -> bool:
	var progress_bar: Sprite2D
	var remaining_cooldown: int
	var visual_tag: StringName = VisualTag.DEFAULT

	progress_bar = SpriteState.get_trap_by_coord(state.progress_bar_coord)
	if progress_bar == null:
		return false

	if is_enter:
		remaining_cooldown = state.max_cooldown - state.cooldown
		visual_tag = VisualTag.get_percent_tag(
				remaining_cooldown, state.max_cooldown
		)
	VisualEffect.switch_sprite(progress_bar, visual_tag)
	return true

