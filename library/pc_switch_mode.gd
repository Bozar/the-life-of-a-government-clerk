class_name PcSwitchMode


const Z_LAYER_HELP: int = 1


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


static func highlight_actor() -> void:
	for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(SubTag.HIGHLIGHT):
		if i.visible:
			VisualEffect.set_default_color(i)


static func help_mode(is_enter: bool) -> void:
	var dh := NodeHub.ref_DataHub

	var pc: Sprite2D = dh.pc
	var z_layer: int = dh.pc.z_index
	var dummy: Sprite2D = dh.dummy_pc
	var coord: Vector2i
	var visual_tag: StringName

	if is_enter:
		coord = dh.pc_coord
		visual_tag = VisualTag.PASSIVE

		SpriteState.move_sprite(pc, coord, z_layer + Z_LAYER_HELP)
		VisualEffect.switch_sprite(pc, visual_tag)
		SpriteFactory.create_actor(SubTag.DUMMY_PC, coord, true)

	else:
		coord = dh.dummy_pc_coord
		visual_tag = VisualTag.DEFAULT

		SpriteFactory.remove_sprite(dummy)
		SpriteState.move_sprite(pc, coord, z_layer - Z_LAYER_HELP)
		VisualEffect.switch_sprite(pc, visual_tag)

