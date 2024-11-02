class_name PcState


var cash: int = GameData.INCOME_INITIAL
var account: int = 0
var delivery: int = GameData.MAX_DELIVERY
var delay: int = 0


var _sprite: Sprite2D


func _init(sprite_: Sprite2D) -> void:
    _sprite = sprite_
