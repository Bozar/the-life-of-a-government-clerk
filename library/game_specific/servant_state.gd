class_name ServantState
extends ActorState


const INVALID_IDLE_DURATION: int = 0


var idle_duration: int = 0:
	set(value):
		idle_duration = value

		var new_tag: StringName

		if is_active:
			if sprite.is_in_group(SubTag.BARNABAS):
				new_tag = VisualTag.ACTIVE_1
			else:
				new_tag = VisualTag.ACTIVE
		else:
			new_tag = VisualTag.DEFAULT
		VisualEffect.switch_sprite(sprite, new_tag)


var max_idle_duration: int:
	get:
		if _max_idle_duration == INVALID_IDLE_DURATION:
			_max_idle_duration = NodeHub.ref_RandomNumber.get_int(
					GameData.MIN_IDLE_DURATION,
					GameData.MAX_IDLE_DURATION + 1
			)
		return _max_idle_duration


var is_active: bool:
	get:
		return idle_duration >= max_idle_duration


var _max_idle_duration: int = INVALID_IDLE_DURATION

