class_name PcAction
extends Node2D


var _is_first_turn: bool = true

var _fov_map: Dictionary = Map2D.init_map(PcFov.DEFAULT_FOV_FLAG)
var _shadow_cast_fov_data := ShadowCastFov.FovData.new(GameData.PC_SIGHT_RANGE)

var _buffer_input_data := HandleGameplayInput.BufferInputData.new()


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
		GameData.NORMAL_MODE:
			if HandleGameplayInput.is_normal_input(
					input_tag, _buffer_input_data
			):
				return
		GameData.EXAMINE_MODE:
			if HandleGameplayInput.is_examine_input(
					input_tag, _buffer_input_data
			):
				return

	PcFov.render_fov(
			NodeHub.ref_DataHub.pc, _fov_map, _shadow_cast_fov_data
	)
	if NodeHub.ref_DataHub.game_mode == GameData.EXAMINE_MODE:
		PcSwitchMode.highlight_actor()
	NodeHub.ref_SignalHub.ui_force_updated.emit()


func _on_SignalHub_game_over(_player_win: bool) -> void:
	PcFov.render_fov(
			NodeHub.ref_DataHub.pc, _fov_map, _shadow_cast_fov_data
	)
	#if not player_win:
	#	VisualEffect.set_dark_color(NodeHub.ref_DataHub.pc)


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

