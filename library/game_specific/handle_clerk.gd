class_name HandleClerk


const DESK_ITEM_TAGS: Dictionary = {
	SubTag.ATLAS: SubTag.ATLAS_ON_DESK,
	SubTag.BOOK: SubTag.BOOK_ON_DESK,
	SubTag.CUP: SubTag.CUP_ON_DESK,
	SubTag.ENCYCLOPEDIA: SubTag.ENCYCLOPEDIA_ON_DESK,
}

const DESK_ITEM_PAGES: Dictionary = {
	SubTag.ATLAS_ON_DESK: GameData.PAGE_ATLAS,
	SubTag.BOOK_ON_DESK: GameData.PAGE_BOOK,
	SubTag.CUP_ON_DESK: GameData.PAGE_CUP,
	SubTag.ENCYCLOPEDIA_ON_DESK: GameData.PAGE_ENCYCLOPEDIA,
}

const DESK_ITEM_PROGRESS: Dictionary = {
	SubTag.ATLAS_ON_DESK: GameData.PROGRESS_ATLAS,
	SubTag.BOOK_ON_DESK: GameData.PROGRESS_BOOK,
	SubTag.CUP_ON_DESK: GameData.PROGRESS_CUP,
	SubTag.ENCYCLOPEDIA_ON_DESK: GameData.PROGRESS_ENCYCLOPEDIA,
}


static func can_send_document(state: ClerkState) -> bool:
	return state.has_document


static func send_document(state: ClerkState) -> void:
	var new_progress: int = state.progress

	new_progress -= GameData.MAX_CLERK_PROGRESS
	new_progress = max(0, new_progress)
	new_progress = floor(GameData.OVERFLOW_PROGRESS * new_progress)
	state.progress = new_progress


static func can_receive_raw_file(
		state: ClerkState, item_tag: StringName
) -> bool:
	var desk_sprite: Sprite2D
	var new_tag: StringName = DESK_ITEM_TAGS.get(item_tag, "")
	var has_empty_desk: bool = false

	if state.has_document:
		return false
	elif new_tag == "":
		return false

	for i: DeskState in state.desk_states:
		desk_sprite = i.sprite
		if desk_sprite == null:
			has_empty_desk = true
		elif desk_sprite.is_in_group(new_tag):
			return false
	return has_empty_desk


static func receive_raw_file(state: ClerkState, item_tag: StringName) -> void:
	var desk_state: DeskState
	var new_tag: StringName
	var new_coord: Vector2i
	var new_tagged_sprite: TaggedSprite

	new_tag = DESK_ITEM_TAGS[item_tag]
	for i: DeskState in state.desk_states:
		# Put a new raw file on the first (closest) empty desk.
		if i.sprite == null:
			desk_state = i
			break

	new_coord = desk_state.coord
	new_tagged_sprite = SpriteFactory.create_trap(new_tag, new_coord, true)
	desk_state.sprite = new_tagged_sprite.sprite
	if DESK_ITEM_PAGES.has(new_tag):
		desk_state.sub_tag = new_tag
		desk_state.max_page = DESK_ITEM_PAGES[new_tag]
		desk_state.remaining_page = DESK_ITEM_PAGES[new_tag]
	else:
		push_error("Page not found: %s" % new_tag)


static func update_progress(state: ClerkState) -> void:
	var remove_sprite: Sprite2D

	if state.has_empty_desk:
		return

	for i: DeskState in state.desk_states:
		# Clean desk before updating progress. Otherwise Clerk sprite
		# may not be switched when progress is full.
		i.remaining_page -= 1
		if i.remaining_page < 1:
			remove_sprite = i.sprite
			i.sprite = null
			SpriteFactory.remove_sprite(remove_sprite)

		state.progress += DESK_ITEM_PROGRESS[i.sub_tag]


static func reduce_progress(
		ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
) -> void:
	var idler: int = ref_DataHub.count_idler
	var leak: int = GameData.PROGRESS_LEAK
	var dup_states: Array

	if (
		Cart.count_cart(ref_DataHub.linked_cart_state)
		> GameData.CART_LENGTH_SHORT
	):
		idler = max(idler, GameData.MIN_LEAK_IDLER)

	if idler < 1:
		return

	dup_states = ref_DataHub.clerk_states.duplicate()
	ArrayHelper.shuffle(dup_states, ref_RandomNumber)
	dup_states.sort_custom(_sort_progress)

	for i: ClerkState in dup_states:
		if not _is_valid_progress(i.progress):
			continue
		#i.progress -= ref_RandomNumber.get_int(
		#		GameData.MIN_PROGRESS_LEAK,
		#		GameData.MAX_PROGRESS_LEAK + 1
		#)
		i.progress -= idler * leak
		i.progress = max(GameData.PROGRESS_CUP, i.progress)
		break


static func switch_examine_mode(is_enter: bool, states: Array) -> void:
	for cs: ClerkState in states:
		_switch_clerk_sprite(is_enter, cs)
		for ds: DeskState in cs.desk_states:
			if ds.sprite == null:
				continue
			_switch_desk_sprite(is_enter, ds)


static func _switch_clerk_sprite(is_examine: bool, state: ClerkState) -> void:
	var visual_tag: StringName

	if is_examine:
		visual_tag = VisualTag.get_percent_tag(
				state.progress, GameData.MAX_CLERK_PROGRESS
		)
		VisualEffect.switch_sprite(state.sprite, visual_tag)
	else:
		if state.has_document:
			visual_tag = VisualTag.ACTIVE
		else:
			visual_tag = VisualTag.DEFAULT
		VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _switch_desk_sprite(is_examine: bool, state: DeskState) -> void:
	var visual_tag: StringName

	if is_examine:
		visual_tag = VisualTag.get_percent_tag(
				state.remaining_page, state.max_page
		)
		VisualEffect.switch_sprite(state.sprite, visual_tag)
	else:
		visual_tag = VisualTag.DEFAULT
		VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _is_valid_progress(progress: int) -> bool:
	return (
			(progress > GameData.PROGRESS_CUP)
			and (progress < GameData.MAX_CLERK_PROGRESS)
	)


static func _sort_progress(left: ClerkState, right: ClerkState) -> bool:
	return left.progress < right.progress

