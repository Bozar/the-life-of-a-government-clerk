class_name HandlePhone


static func answer_call(actor: Sprite2D, ref_DataHub: DataHub) -> void:
	Cart.clean_short_cart(
			ref_DataHub.pc, ref_DataHub.linked_cart_state,
			GameData.CLEAN_PHONE_CALL
			)
	SpriteFactory.remove_sprite(actor)

