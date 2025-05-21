class_name DungeonPrefab


enum {
	DO_NOT_TRANSFORM,
	FLIP_HORIZONTALLY,
	FLIP_VERTICALLY,
	ROTATE_RIGHT,
	ROTATE_LEFT,
}


# output_line: {int line_number: String line_text}
# transforms: FLIP_HORIZONTALLY | FLIP_VERTICALLY | ROTATE_RIGHT | ROTATE_LEFT
static func get_prefab(
		output_line: Dictionary, transforms: Array
) -> PackedPrefab:
	var prefab: Dictionary = {}
	var max_x: int = output_line[0].length()
	var max_y: int = output_line.size()
	var swap_xy: int
	var new_row: Array
	var refresh_size: bool = false

	# The file is read by lines. Therefore in order to get a grid (x, y), we
	# need to call output_line[y][x], which is inconvenient. Swap (x, y) and
	# (y, x) to make life easier.
	#
	# column
	# ----------> x
	# |
	# | row
	# |
	# v y
	for x: int in range(0, max_x):
		new_row = []
		new_row.resize(max_y)
		prefab[x] = new_row
		for y: int in range(0, max_y):
			prefab[x][y] = output_line[y][x]

	# 1. The top left corner is the origin point (0, 0). The whole rectangle
	# falls in the zone between 3 and 6 o'clock.
	# 2. Transform in accordance to x axis, y axis, or the origin point.
	# 3. Move down or right until the new top left corner reaches the origin
	# point.
	for i: int in transforms:
		refresh_size = _transform_prefab(i, max_x, max_y, prefab)
		# Update max_x and max_y after the prefab is rotated.
		if refresh_size:
			swap_xy = max_x
			max_x = max_y
			max_y = swap_xy
			refresh_size = false
	return PackedPrefab.new(prefab)


static func _flip_horizontally(
		prefab: Dictionary, max_x: int, max_y: int
) -> Dictionary:
	var mirror: int

	for y: int in range(0, max_y):
		for x: int in range(0, max_x):
			mirror = max_x - x - 1
			if x > mirror:
				break
			_swap_matrix_value(
					prefab,
					Vector2i(x, y), Vector2i(mirror, y)
			)
	return prefab


static func _flip_vertically(
		prefab: Dictionary, max_x: int, max_y: int
) -> Dictionary:
	var mirror: int

	for x: int in range(0, max_x):
		for y: int in range(0, max_y):
			mirror = max_y - y - 1
			if y > mirror:
				break
			_swap_matrix_value(
					prefab,
					Vector2i(x, y), Vector2i(x, mirror)
			)
	return prefab


static func _rotate_right(
		prefab: Dictionary, max_x: int, max_y: int
) -> Dictionary:
	var new_prefab: Dictionary = _get_new_matrix(max_x, max_y)
	var new_x: int
	var new_y: int

	for x: int in range(0, max_x):
		for y: int in range(0, max_y):
			new_x = max_y - y - 1
			new_y = x
			new_prefab[new_x][new_y] = prefab[x][y]
	return new_prefab


static func _rotate_left(
		prefab: Dictionary, max_x: int, max_y: int
) -> Dictionary:
	var new_prefab: Dictionary = _get_new_matrix(max_x, max_y)
	var new_x: int
	var new_y: int

	for x: int in range(0, max_x):
		for y: int in range(0, max_y):
			new_x = y
			new_y = max_x - x - 1
			new_prefab[new_x][new_y] = prefab[x][y]
	return new_prefab


static func _swap_matrix_value(
		matrix: Dictionary, this_coord: Vector2i, that_coord: Vector2i
) -> void:
	var save_char: String = matrix[this_coord.x][this_coord.y]

	matrix[this_coord.x][this_coord.y] = matrix[that_coord.x][that_coord.y]
	matrix[that_coord.x][that_coord.y] = save_char


static func _get_new_matrix(max_x: int, max_y: int) -> Dictionary:
	var new_matrix: Dictionary = {}
	var new_row: Array

	for x: int in range(0, max_y):
		new_row = []
		new_row.resize(max_x)
		new_matrix[x] = new_row
	return new_matrix


static func _transform_prefab(
		transform: int, max_x: int, max_y: int, out_prefab: Dictionary
) -> bool:
	match transform:
		FLIP_HORIZONTALLY:
			out_prefab = _flip_horizontally(
					out_prefab, max_x, max_y
			)
			return false
		FLIP_VERTICALLY:
			out_prefab = _flip_vertically(out_prefab, max_x, max_y)
			return false
		ROTATE_RIGHT:
			out_prefab = _rotate_right(out_prefab, max_x, max_y)
			return true
		ROTATE_LEFT:
			out_prefab = _rotate_left(out_prefab, max_x, max_y)
			return true
	return false

