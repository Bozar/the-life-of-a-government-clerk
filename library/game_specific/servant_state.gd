class_name ServantState
extends ActorState


const INVALID_IDLE_DURATION: int = 0


var idle_duration: int = 0:
	set(value):
		idle_duration = value
		if is_active:
			VisualEffect.switch_sprite(sprite, VisualTag.ACTIVE)
		else:
			VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)


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

