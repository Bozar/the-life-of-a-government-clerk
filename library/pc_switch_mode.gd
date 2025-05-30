class_name PcSwitchMode


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
	HandleEmptyCart.switch_examine_mode(
			is_enter,
			ref_DataHub.get_actor_states(SubTag.EMPTY_CART)
	)


static func highlight_actor() -> void:
	for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(SubTag.HIGHLIGHT):
		if i.visible:
			VisualEffect.set_default_color(i)

