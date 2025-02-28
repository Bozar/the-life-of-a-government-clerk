class_name ProgressState


var ground_coords: Array
var ground_index: int = 0
var phone_coords: Array = [
    Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 1),
    Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
]
# Set `phone_index` to an invalid value, so as to randomize `phone_coords`
# before the first use.
var phone_index: int = 99
var max_trap: int
var max_leak_repeat: int


var challenge_level: int = 0:
    set(value):
        challenge_level = max(0,
                min(value, GameData.CHALLENGES_PER_DELIVERY.size() - 1)
                )
