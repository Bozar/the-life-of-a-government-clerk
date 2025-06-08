class_name CheckChallenge


static func is_failed(challenge_tag: int) -> bool:
	match challenge_tag:
		ChallengeTag.SHORT_CART:
			return _is_failed_short_cart()
		ChallengeTag.LONG_CART:
			return _is_failed_long_cart()
		ChallengeTag.SHELF:
			return _is_failed_shelf()
	return false


static func _is_failed_short_cart() -> bool:
	var count: int = Cart.count_cart(NodeHub.ref_DataHub.linked_cart_state)
	return count > GameData.CART_LENGTH_SHORT


static func _is_failed_long_cart() -> bool:
	var count: int = Cart.count_cart(NodeHub.ref_DataHub.linked_cart_state)
	return count <= GameData.CART_LENGTH_SHORT


static func _is_failed_shelf() -> bool:
	for i: ShelfState in NodeHub.ref_DataHub.shelf_states:
		if i.item_tag != "":
			return false
	return true

