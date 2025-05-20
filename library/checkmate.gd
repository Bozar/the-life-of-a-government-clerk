class_name Checkmate


const PASSABLE_TAGS: Array = [
	SubTag.DUNGEON_FLOOR,
	SubTag.INTERNAL_FLOOR,
	SubTag.DOOR,
	SubTag.SERVANT,
	SubTag.TRASH,
	SubTag.EMPTY_CART,
]


static func is_game_over(ref_DataHub: DataHub) -> bool:
	if _is_trapped(ref_DataHub.pc_coord):
		return true
	elif _is_fully_loaded(ref_DataHub):
		return true
	return false


# Return true if PC cannot move in any direction.
static func _is_trapped(check_coord: Vector2i) -> bool:
	var neighbor: Array = ConvertCoord.get_diamond_coords(check_coord, 1)
	var sprites: Array
	var top_sprite: Sprite2D

	for coord in neighbor:
		# Filter out a coord if it is in the center or outside the
		# dungeon.
		if (coord.x == check_coord.x) and (coord.y == check_coord.y):
			continue
		elif not DungeonSize.is_in_dungeon(coord):
			continue
		# Get sprites in the specific grid. The grid is passable if the
		# top sprite is `DUNGEON_FLOOR`, `INTERNAL_FLOOR` or `DOOR`.
		sprites = SpriteState.get_sprites_by_coord(coord)
		if sprites.is_empty():
			continue
		sprites.sort_custom(_sort_by_index)
		top_sprite = sprites.pop_back()
		for sub_tag in PASSABLE_TAGS:
			if top_sprite.is_in_group(sub_tag):
				return false
	return true


static func _sort_by_index(lower: Sprite2D, higher: Sprite2D) -> bool:
	return lower.z_index <= higher.z_index


static func _is_fully_loaded(ref_DataHub: DataHub) -> bool:
	var current_cart: int = Cart.count_cart(ref_DataHub.linked_cart_state)
	var current_load: int = Cart.get_full_load_amount(
			ref_DataHub.pc, ref_DataHub.linked_cart_state
	)

	if current_cart < 1:
		return false
	return current_load >= current_cart * GameData.MAX_LOAD_PER_CART

