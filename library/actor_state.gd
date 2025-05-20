class_name ActorState


var sprite: Sprite2D:
	get:
		return _sprite


var sub_tag: StringName:
	get:
		return _sub_tag


var coord: Vector2i:
	get:
		return ConvertCoord.get_coord(sprite)


var _sprite: Sprite2D
var _sub_tag: StringName


func _init(sprite_: Sprite2D, sub_tag_: StringName) -> void:
	_sprite = sprite_
	_sub_tag = sub_tag_

