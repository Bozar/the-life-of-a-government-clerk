class_name EmptyCartState
extends ActorState


const INVALID_DURATION: int = 0


var duration: int = 0


var max_duration: int:
	get:
		if _max_duration == INVALID_DURATION:
			_max_duration = NodeHub.ref_RandomNumber.get_int(
					GameData.MIN_EMPTY_CART_DURATION,
					GameData.MAX_EMPTY_CART_DURATION + 1
			)
		return _max_duration


var _max_duration: int = INVALID_DURATION

