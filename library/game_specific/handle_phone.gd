class_name HandlePhone


static func answer_call(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    Cart.clean_short_cart(
            ref_PcAction.pc, ref_PcAction.linked_cart_state,
            GameData.CLEAN_PHONE_CALL
            )
    SpriteFactory.remove_sprite(actor)

