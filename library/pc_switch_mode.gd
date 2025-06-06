class_name PcSwitchMode


const Z_LAYER_MOD: int = 1


static func examine_mode(is_enter: bool, ref_DataHub: DataHub) -> void:
	HandleClerk.switch_examine_mode(is_enter, ref_DataHub.clerk_states)
	HandleRawFile.switch_examine_mode(is_enter, ref_DataHub.raw_file_states)
	HandleServant.switch_examine_mode(
			is_enter,
			ref_DataHub.get_actor_states(SubTag.SERVANT)
	)
	HandlePhoneBooth.switch_examine_mode(
			is_enter, ref_DataHub.phone_booth_sprites
	)
	HandleDoor.switch_examine_mode(is_enter)
	HandleEmptyCart.switch_examine_mode(
			is_enter,
			ref_DataHub.get_actor_states(SubTag.EMPTY_CART)
	)

	if is_enter:
		_enter_examine_mode()
	else:
		_exit_examine_mode()


static func highlight_actor() -> void:
	for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(SubTag.HIGHLIGHT):
		if i.visible:
			VisualEffect.set_default_color(i)


static func help_mode(is_enter: bool) -> void:
	var dh := NodeHub.ref_DataHub

	var z_layer: int = dh.pc.z_index
	var coord: Vector2i

	if is_enter:
		coord = dh.pc_coord
		SpriteState.move_sprite(dh.pc, coord, z_layer + Z_LAYER_MOD)
		VisualEffect.switch_sprite(dh.pc, VisualTag.PASSIVE)
		SpriteFactory.create_actor(SubTag.DUMMY_PC, coord, true)

	else:
		coord = dh.dummy_pc_coord
		SpriteFactory.remove_sprite(dh.dummy_pc)
		SpriteState.move_sprite(dh.pc, coord, z_layer - Z_LAYER_MOD)
		set_normal_sprite()


static func set_normal_sprite() -> void:
	var dh := NodeHub.ref_DataHub

	var visual_tag: StringName

	if Cart.is_safe_load_amount_percent(
			Cart.SAFE_LOAD.FULL_LINE,
			GameData.SAFE_LOAD_AMOUNT_PERCENT_3,
			dh
	):
		visual_tag = VisualTag.DEFAULT
	else:
		visual_tag = VisualTag.ACTIVE

	VisualEffect.switch_sprite(dh.pc, visual_tag)


static func _enter_examine_mode() -> void:
	var dh := NodeHub.ref_DataHub

	var cart: Sprite2D = LinkedList.get_next_object(
			dh.pc, dh.linked_cart_state.linked_carts
	)
	var coord: Vector2i = ConvertCoord.get_coord(cart)

	dh.linked_cart_state.save_pc_coord = dh.pc_coord
	# By game design, PC can move over cart sprites.
	SpriteState.move_sprite(dh.pc, coord, dh.pc.z_index + Z_LAYER_MOD)
	VisualEffect.switch_sprite(dh.pc, VisualTag.PASSIVE)


static func _exit_examine_mode() -> void:
	var dh := NodeHub.ref_DataHub

	SpriteState.move_sprite(
			dh.pc, dh.linked_cart_state.save_pc_coord,
			dh.pc.z_index - Z_LAYER_MOD
	)
	set_normal_sprite()

