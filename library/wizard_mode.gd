class_name WizardMode


static func handle_input(input_tag: StringName) -> void:
	var dh := NodeHub.ref_DataHub

	match input_tag:
		InputTag.WIZARD_1:
			Cart.clean_cart(dh.pc, dh.linked_cart_state)

		InputTag.WIZARD_2:
			_reset_cooldown()

		InputTag.WIZARD_3:
			dh.cash += 1

		InputTag.WIZARD_4:
			Cart.add_cart(GameData.ADD_CART, dh.linked_cart_state)

		InputTag.WIZARD_5:
			_add_document()

		InputTag.WIZARD_6:
			NodeHub.ref_DataHub.show_all_sprite = true


static func _add_document() -> void:
	var dh := NodeHub.ref_DataHub
	var sprite: Sprite2D =	Cart.get_last_slot(dh.pc, dh.linked_cart_state)
	var state: CartState

	if sprite == null:
		return
	state = Cart.get_state(sprite, dh.linked_cart_state)
	state.item_tag = SubTag.DOCUMENT


static func _reset_cooldown() -> void:
	for i: RawFileState in NodeHub.ref_DataHub.raw_file_states:
		i.cooldown = 0

