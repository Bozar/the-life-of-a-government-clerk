class_name PcState


var cash: int = 0
var account: int = 0
var delivery: int = GameData.MAX_DELIVERY


var has_stick: bool = false:
    set(value):
        var new_tag: StringName

        has_stick = value
        new_tag = VisualTag.ACTIVE if has_stick else VisualTag.DEFAULT
        VisualEffect.switch_sprite(_sprite, new_tag)


var _sprite: Sprite2D


func _init(sprite_: Sprite2D) -> void:
    _sprite = sprite_
