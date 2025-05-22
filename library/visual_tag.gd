class_name VisualTag


const DEFAULT: StringName = &"default"
const ACTIVE: StringName = &"active"
const PASSIVE: StringName = &"passive"

const ACTIVE_1: StringName = &"active_1"
const ACTIVE_2: StringName = &"active_2"
const ACTIVE_3: StringName = &"active_3"
const ACTIVE_4: StringName = &"active_4"
const ACTIVE_5: StringName = &"active_5"
const ACTIVE_6: StringName = &"active_6"
const ACTIVE_7: StringName = &"active_7"
const ACTIVE_8: StringName = &"active_8"
const ACTIVE_9: StringName = &"active_9"

const PASSIVE_1: StringName = &"passive_1"
const PASSIVE_2: StringName = &"passive_2"

const LEFT: StringName = &"left"
const RIGHT: StringName = &"right"
const UP: StringName = &"up"
const DOWN: StringName = &"down"

const ZERO: StringName = &"zero"
const ONE: StringName = &"one"
const TWO: StringName = &"two"
const THREE: StringName = &"three"
const FOUR: StringName = &"four"
const FIVE: StringName = &"five"
const SIX: StringName = &"six"
const SEVEN: StringName = &"seven"
const EIGHT: StringName = &"eight"
const NINE: StringName = &"nine"
const PERCENT: StringName = &"percent"


const DIGIT_TO_TAG: Dictionary = {
	0: ZERO,
	1: ONE,
	2: TWO,
	3: THREE,
	4: FOUR,
	5: FIVE,
	6: SIX,
	7: SEVEN,
	8: EIGHT,
	9: NINE,
}

const VECTOR_TO_TAG: Dictionary = {
	Vector2i.LEFT: LEFT,
	Vector2i.RIGHT: RIGHT,
	Vector2i.UP: UP,
	Vector2i.DOWN: DOWN,
}


# Get the percent value of `current_value / max_value`. Keep the tens digit and
# return its visual tag.
static func get_percent_tag(current_value: int, max_value: int) -> StringName:
	var tens_digit: int = int(abs(current_value / (max_value * 1.0) * 10.0))
	return DIGIT_TO_TAG.get(tens_digit, PERCENT)

