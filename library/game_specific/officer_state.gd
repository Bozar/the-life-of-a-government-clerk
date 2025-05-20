class_name OfficerState
extends ActorState


var is_active: bool = true:
	set(value):
		is_active = value
		if is_active:
			VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)
		else:
			VisualEffect.switch_sprite(sprite, VisualTag.PASSIVE)

