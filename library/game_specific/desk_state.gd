class_name DeskState


var coord: Vector2i:
    get:
        return _coord


var sprite: Sprite2D
var remaining_page: int
var max_page: int
var sub_tag: StringName


var _coord: Vector2i


func _init(coord_: Vector2i) -> void:
    _coord = coord_
