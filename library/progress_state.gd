class_name ProgressState


var ground_coords: Array
var ground_index: int = 0
var phone_coords: Array
var phone_index: int = 0
var max_trap: int
var max_phone: int


var turn_counter: int = GameData.MIN_TURN_COUNTER:
    set(value):
        if value > GameData.MAX_TURN_COUNTER:
            turn_counter = GameData.MIN_TURN_COUNTER
        else:
            turn_counter = max(value, GameData.MIN_TURN_COUNTER)


var challenge_level: int = 0:
    set(value):
        challenge_level = max(0, min(value, GameData.MAX_LEVEL))

