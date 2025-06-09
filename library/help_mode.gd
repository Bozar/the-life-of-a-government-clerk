class_name HelpMode


const COORD: String = "?> %d, %d"
const INVALID_TAG: String = "?> ?-??"


static func get_sidebar_text() -> String:
	var snippets: Array = _get_tags()

	snippets[0] = _get_coord()
	return "\n".join(snippets)


static func _get_coord() -> String:
	var dh := NodeHub.ref_DataHub

	var pc_coord: Vector2i = dh.pc_coord
	var dummy_coord: Vector2i = dh.dummy_pc_coord

	return COORD % [
		pc_coord.x - dummy_coord.x,
		pc_coord.y - dummy_coord.y,
	]


static func _get_tags() -> Array:
	var dh := NodeHub.ref_DataHub

	# The first element is reserved for `_get_coord()`.
	var tags: Array = [""]

	if not NodeHub.ref_PcAction.is_fov_flag(
			dh.pc_coord, PcFov.IS_IN_MEMORY_FLAG
	):
		return tags

	var sprites: Array = SpriteState.get_sprites_by_coord(dh.pc_coord)

	sprites.sort_custom(SpriteState.sort_by_z_index)
	if not sprites[-1].is_in_group(SubTag.PC):
		push_error("Invalid top sprite: %s" % sprites[-1])
		return tags

	sprites.pop_back()
	sprites.reverse()
	# Add a blank line.
	tags.push_back("")

	var sub_tag: StringName

	for i: Sprite2D in sprites:
		sub_tag = SpriteState.get_sub_tag(i)
		tags.push_back(SubTag.TAG_TO_HELP.get(sub_tag, INVALID_TAG))
	return tags

