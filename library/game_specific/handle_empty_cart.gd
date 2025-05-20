class_name HandleEmptyCart


static func update_duration(state: EmptyCartState) -> void:
	state.duration += 1
	if state.duration >= state.max_duration:
		SpriteFactory.create_trap(SubTag.TRASH, state.coord, true)
		SpriteFactory.remove_sprite(state.sprite)


static func switch_examine_mode(is_enter: bool, states: Array) -> void:
	var visual_tag: StringName

	for i: EmptyCartState in states:
		if is_enter:
			visual_tag = VisualTag.get_percent_tag(
					i.duration, i.max_duration
			)
		else:
			visual_tag = VisualTag.DEFAULT
		VisualEffect.switch_sprite(i.sprite, visual_tag)

