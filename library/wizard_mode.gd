class_name WizardMode


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
            PcHitActor._load_document(NodeHub.ref_PcAction)
