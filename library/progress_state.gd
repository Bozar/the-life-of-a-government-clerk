class_name ProgressState


var ground_coords: Array
var ground_index: int = 0
var phone_coords: Array
var phone_index: int = 0
var max_trap: int


var challenge_level: int = 0:
    set(value):
        challenge_level = max(0, min(value, GameData.MAX_LEVEL))

