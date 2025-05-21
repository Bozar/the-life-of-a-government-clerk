class_name DiamondFov


# _set_fov_value(coord: Vector2i, fov_map: Dictionary, fov_flag: int,
#> is_truthy: bool) -> void
static func get_fov_map(
		source: Vector2i, out_fov_map: Dictionary,
		set_fov_value: Callable, sight_range: int
) -> void:
	var column: Array
	var coord: Vector2i = Vector2i(0, 0)
	var is_in_range: bool

	for x: int in out_fov_map.keys():
		column = out_fov_map[x]
		for y: int in range(0, column.size()):
			_set_fov_xy(
					x, y,
					source, out_fov_map,
					set_fov_value, sight_range
			)


static func _set_fov_xy(
		x: int, y: int,
		source: Vector2i, out_fov_map: Dictionary,
		set_fov_value: Callable, sight_range: int
) -> void:
	var coord: Vector2i = Vector2i(0, 0)
	var is_in_range: bool

	coord.x = x
	coord.y = y
	is_in_range = ConvertCoord.is_in_range(source, coord, sight_range)
	set_fov_value.call(
			coord, out_fov_map,
			PcFov.IS_IN_SIGHT_FLAG, is_in_range
	)

