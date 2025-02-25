class_name WizardMode


const test_phone_coords: Array = [
    Vector2i(1, 1),
    Vector2i(1, 2),
    Vector2i(2, 1),
]


static func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


static func _test(input_tag: StringName) -> void:
    match input_tag:
        InputTag.WIZARD_1:
            Cart.add_cart(
                    GameData.ADD_CART, NodeHub.ref_PcAction.linked_cart_state
                    )
        InputTag.WIZARD_2:
            NodeHub.ref_PcAction.cash += 1
        InputTag.WIZARD_3:
            Cart.clean_cart(NodeHub.ref_PcAction.pc,
                    NodeHub.ref_PcAction.linked_cart_state)
        InputTag.WIZARD_4:
            NodeHub.ref_PcAction.delivery -= 1
        InputTag.WIZARD_5:
            _create_phone()
        InputTag.WIZARD_6:
            PcHitActor._load_document(NodeHub.ref_PcAction)


static func _create_phone() -> void:
    for i: Vector2i in test_phone_coords:
        if SpriteState.has_actor_at_coord(i):
            continue
        SpriteFactory.create_actor(SubTag.PHONE, i, true)
