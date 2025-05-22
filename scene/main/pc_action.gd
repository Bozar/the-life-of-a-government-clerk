class_name PcAction
extends Node2D


enum {
	NORMAL_MODE,
	EXAMINE_MODE,
}

const INVALID_COORD: Vector2i = Vector2i(-1, -1)


var _is_first_turn: bool = true

var _fov_map: Dictionary = Map2D.init_map(PcFov.DEFAULT_FOV_FLAG)
var _shadow_cast_fov_data := ShadowCastFov.FovData.new(GameData.PC_SIGHT_RANGE)

var _buffer_coord: Vector2i = INVALID_COORD


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
	for i: TaggedSprite in tagged_sprites:
		_init_sprite(i.sub_tag, i.sprite)


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
	for i: Sprite2D in sprites:
		if i.is_in_group(SubTag.PHONE):
			NodeHub.ref_DataHub.add_incoming_call(-1)


func _on_SignalHub_turn_started(sprite: Sprite2D) -> void:
	if not sprite.is_in_group(SubTag.PC):
		return

	# Wait 1 frame when the very first turn starts, so that sprites from the
	# previous scene are properly removed.
	if _is_first_turn:
		await get_tree().create_timer(0).timeout
		_is_first_turn = false
	else:
		# Do not update turn counter because it is already 1 in the
		# first turn.
		GameProgress.update_turn_counter(NodeHub.ref_DataHub)

	GameProgress.update_world(NodeHub.ref_DataHub, NodeHub.ref_RandomNumber)

	if Checkmate.is_game_over(NodeHub.ref_DataHub):
		NodeHub.ref_SignalHub.game_over.emit(false)
		return
	elif NodeHub.ref_DataHub.delay > 0:
		NodeHub.ref_DataHub.delay -= 1
		Cart.add_trash(
				NodeHub.ref_DataHub.pc,
				NodeHub.ref_DataHub.linked_cart_state,
				NodeHub.ref_RandomNumber
		)

		# The game loops without player's input. If call
		# start_next_turn() directly, there might be a stack overflow
		# error when too many turns are delayed (more than 10?).
		NodeHub.ref_Schedule.call_deferred("start_next_turn")

		# Another way is to wait until the next frame.
		# https://godotforums.org/d/35537-looking-for-a-way-to-signal-a-funtion-to-be-called-on-the-next-frame/7
		#
		# await get_tree().create_timer(0).timeout

		return
	PcFov.render_fov(
			NodeHub.ref_DataHub.pc, _fov_map, _shadow_cast_fov_data
	)


func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
	match NodeHub.ref_DataHub.game_mode:
		NORMAL_MODE:
			if _handle_normal_input(input_tag):
				return
		EXAMINE_MODE:
			if _handle_examine_input(input_tag):
				return

	PcFov.render_fov(
			NodeHub.ref_DataHub.pc, _fov_map, _shadow_cast_fov_data
	)
	if NodeHub.ref_DataHub.game_mode == EXAMINE_MODE:
		PcSwitchMode.highlight_actor()
	NodeHub.ref_SignalHub.ui_force_updated.emit()


func _on_SignalHub_game_over(player_win: bool) -> void:
	PcFov.render_fov(
			NodeHub.ref_DataHub.pc, _fov_map, _shadow_cast_fov_data
	)
	if not player_win:
		VisualEffect.set_dark_color(NodeHub.ref_DataHub.pc)


func _move(direction: Vector2i, state: LinkedCartState) -> void:
	var coord: Vector2i = (
			ConvertCoord.get_coord(NodeHub.ref_DataHub.pc)
			+ direction
	)
	var sprite: Sprite2D
	var sub_tag: StringName

	if not DungeonSize.is_in_dungeon(coord):
		return

	elif _try_buffer_input(direction, coord):
		return

	# Order matters in `The Life of a Government Clerk`. An actor may appear
	# above a building and therefore has a higher priority.
	elif SpriteState.has_actor_at_coord(coord):
		sprite = SpriteState.get_actor_by_coord(coord)
		sub_tag = SpriteState.get_sub_tag(sprite)
		PcHitActor.handle_input(
				sprite, NodeHub.ref_DataHub,
				NodeHub.ref_ActorAction,
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


func _handle_normal_input(input_tag: StringName) -> bool:
	var dh := NodeHub.ref_DataHub

	match input_tag:
		InputTag.SWITCH_EXAMINE:
			if not Cart.enter_examine_mode(
					dh.pc, dh.linked_cart_state
			):
				return true
			dh.set_game_mode(EXAMINE_MODE)
			PcSwitchMode.examine_mode(
					true, dh,
					NodeHub.ref_ActorAction
			)
			return false

		InputTag.MOVE_LEFT:
			_move(Vector2i.LEFT, dh.linked_cart_state)
			return true
		InputTag.MOVE_RIGHT:
			_move(Vector2i.RIGHT, dh.linked_cart_state)
			return true
		InputTag.MOVE_UP:
			_move(Vector2i.UP, dh.linked_cart_state)
			return true
		InputTag.MOVE_DOWN:
			_move(Vector2i.DOWN, dh.linked_cart_state)
			return true

		InputTag.WIZARD_1, InputTag.WIZARD_2, \
				InputTag.WIZARD_3, InputTag.WIZARD_4, \
				InputTag.WIZARD_5, InputTag.WIZARD_6, \
				InputTag.WIZARD_7, InputTag.WIZARD_8, \
				InputTag.WIZARD_9, InputTag.WIZARD_0:
			WizardMode.handle_input(input_tag)
			return false

	return true


func _handle_examine_input(input_tag: StringName) -> bool:
	var dh := NodeHub.ref_DataHub

	match input_tag:
		InputTag.SWITCH_EXAMINE, InputTag.EXIT_EXAMINE:
			# Reset buffer state when leaving Examine Mode.
			_set_buffer_state(INVALID_COORD, INVALID_COORD, false)
			dh.set_game_mode(NORMAL_MODE)
			Cart.exit_examine_mode(
					dh.pc, dh.linked_cart_state
			)
			PcSwitchMode.examine_mode(
					false, dh, NodeHub.ref_ActorAction
			)

		InputTag.MOVE_UP:
			Cart.examine_first_cart(
					dh.pc, dh.linked_cart_state
			)
		InputTag.MOVE_DOWN:
			Cart.examine_last_cart(
					dh.pc, dh.linked_cart_state
			)
		InputTag.MOVE_LEFT:
			Cart.examine_previous_cart(
					dh.pc, dh.linked_cart_state
			)
		InputTag.MOVE_RIGHT, InputTag.EXAMINE_NEXT_CART:
			Cart.examine_next_cart(
					dh.pc, dh.linked_cart_state
			)

		_:
			return true
	return false


func _init_pc(pc_sprite: Sprite2D) -> void:
	NodeHub.ref_DataHub.set_pc(pc_sprite)
	Cart.init_linked_carts(
			NodeHub.ref_DataHub.pc,
			NodeHub.ref_DataHub.linked_cart_state
	)
	Cart.add_cart(GameData.MIN_CART, NodeHub.ref_DataHub.linked_cart_state)


func _init_sprite(sub_tag: StringName, sprite: Sprite2D) -> void:
	match sub_tag:
		SubTag.PC:
			if NodeHub.ref_DataHub.pc != null:
				return
			_init_pc(sprite)

		SubTag.PHONE:
			NodeHub.ref_DataHub.add_incoming_call(1)


func _try_buffer_input(direction: Vector2i, coord: Vector2i) -> bool:
	var is_same_input: bool

	# There is a buffer input.
	if _buffer_coord != INVALID_COORD:
		is_same_input = (_buffer_coord == coord)
		# Always reset buffer state.
		_set_buffer_state(INVALID_COORD, INVALID_COORD, false)
		# The same input key is pressed the second time. Pass the key to
		# following code outside `_try_buffer_input()`.
		if is_same_input:
			return false
		# Another input key is pressed. Check whether to buffer the key
		# normally.
		else:
			pass

	var sprite: Sprite2D
	var sub_tag: StringName
	var has_servant: bool = false

	# It's safe to interact with a Building.
	if SpriteState.has_building_at_coord(coord):
		return false
	# Only try to buffer an input when interacting with a Servant.
	sprite = SpriteState.get_actor_by_coord(coord)
	if sprite != null:
		sub_tag = SpriteState.get_sub_tag(sprite)
		if sub_tag != SubTag.SERVANT:
			return false
		has_servant = true

	var mirror_coord: Vector2i
	var top_sprite: Sprite2D

	# Warn player when he might be trapped.
	if Checkmate.is_trapped(coord):
		_set_buffer_state(direction, coord, true)
		return true
	# Warn player when a Servant being pushed might disappear.
	elif not has_servant:
		return false
	elif PcHitActor.can_load_servant(NodeHub.ref_DataHub):
		return false
	mirror_coord = ConvertCoord.get_mirror_coord(
			NodeHub.ref_DataHub.pc_coord, coord
	)
	if not DungeonSize.is_in_dungeon(mirror_coord):
		_set_buffer_state(direction, coord, true)
		return true
	top_sprite = SpriteState.get_top_sprite_by_coord(mirror_coord)
	if top_sprite == null:
		return false
	elif (
			top_sprite.is_in_group(MainTag.BUILDING)
			or top_sprite.is_in_group(MainTag.ACTOR)
			or top_sprite.is_in_group(MainTag.TRAP)
	):
		_set_buffer_state(direction, coord, true)
		return true

	return false


func _set_buffer_state(
		direction: Vector2i, coord: Vector2i, has_new_input: bool, 
) -> void:
	var visual_tag: StringName

	if has_new_input:
		visual_tag = VisualTag.VECTOR_TO_TAG.get(
			direction, VisualTag.DEFAULT
		)
		_buffer_coord = coord
	else:
		visual_tag = VisualTag.DEFAULT
		_buffer_coord = INVALID_COORD
	VisualEffect.switch_sprite(NodeHub.ref_DataHub.pc, visual_tag)

