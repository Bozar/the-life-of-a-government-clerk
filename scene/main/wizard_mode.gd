class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    _test(input_tag)


func _test(input_tag: StringName) -> void:
    var ref_pc_action: PcAction = get_node("..")
    var linked_state: LinkedCartState = ref_pc_action._linked_cart_state

    match input_tag:
        InputTag.WIZARD_1:
            Cart.add_cart(GameData.ADD_CART, linked_state)
        InputTag.WIZARD_2:
            ref_pc_action.cash += 1
        InputTag.WIZARD_3:
            ref_pc_action.clean_cart()
