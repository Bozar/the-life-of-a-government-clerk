class_name WizardMode


static func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


static func _test(input_tag: StringName) -> void:
    match input_tag:
        InputTag.WIZARD_1:
            Cart.add_cart(
                    GameData.ADD_CART, NodeHub.ref_DataHub.linked_cart_state
                    )

        InputTag.WIZARD_2:
            NodeHub.ref_DataHub.cash += 1

        InputTag.WIZARD_3:
            Cart.clean_cart(NodeHub.ref_DataHub.pc,
                    NodeHub.ref_DataHub.linked_cart_state)

        InputTag.WIZARD_4:
            var sprite: Sprite2D =  Cart.get_last_slot(
                    NodeHub.ref_DataHub.pc,
                    NodeHub.ref_DataHub.linked_cart_state
                    )
            var state: CartState
            if sprite != null:
                state = Cart.get_state(
                        sprite, NodeHub.ref_DataHub.linked_cart_state
                        )
                state.item_tag = SubTag.DOCUMENT

