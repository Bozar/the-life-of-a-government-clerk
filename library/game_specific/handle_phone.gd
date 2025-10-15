class_name HandlePhone


static func answer_call(actor: Sprite2D, ref_DataHub: DataHub) -> void:
	Cart.clean_short_cart(
			ref_DataHub.pc, ref_DataHub.linked_cart_state,
			GameData.CLEAN_PHONE_CALL
			)

	SpriteFactory.remove_sprite(actor)
	_create_klamm(ConvertCoord.get_coord(actor), ref_DataHub)


static func _create_klamm(coord: Vector2i, ref_DataHub: DataHub) -> void:
	if ref_DataHub.turn_counter % GameData.KLAMM_TURN_COUNTER != 0:
		return
	elif not SpriteState.get_sprites_by_sub_tag(SubTag.KLAMM).is_empty():
		return
	elif ref_DataHub.count_idler < GameData.KLAMM_IDLER:
		return

	SpriteFactory.create_actor(SubTag.KLAMM, coord, true)

	for i: OfficerState in ref_DataHub.officer_states:
		if i.is_active:
			i.is_active = false
			i.has_klamm_phone_call = true
	for i: ActorState in ref_DataHub.clerk_states:
		VisualEffect.switch_sprite(i.sprite, VisualTag.PASSIVE)

