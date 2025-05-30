class_name InitWorld


const DEBUG: bool = true
const PERCENT_CHANCE: int = 50
const INDICATOR_OFFSET: int = 32

const PATH_TO_ROOM: StringName = "res://resource/dungeon_prefab/room/"
const PATH_TO_QUARTER: StringName = "res://resource/dungeon_prefab/quarter/"
const TRANSFORM_TAGS: Array = [
	DungeonPrefab.FLIP_VERTICALLY, DungeonPrefab.FLIP_HORIZONTALLY,
]

const INDEX_TO_START_COORD: Dictionary = {
	0: Vector2i(1, 1),
	1: Vector2i(7, 0),
	2: Vector2i(0, 6),
	3: Vector2i(14, 9),
}


const WALL_CHAR: StringName = "#"
const OPTIONAL_WALL_CHAR: StringName = "?"
const DOOR_CHAR: StringName = "+"
const DESK_CHAR: StringName = "="
const SPECIAL_FLOOR_CHAR: StringName = "-"
const PHONE_BOOTH_CHAR: StringName = "P"
const SHELF_CHAR: StringName = "%"

const CLERK_CHAR: StringName = "C"
const OFFICER_CHAR: StringName = "O"

const RAW_FILE_A_CHAR: StringName = "A"
const RAW_FILE_B_CHAR: StringName = "B"
const SERVICE_1_CHAR: StringName = "1"
const SERVICE_2_CHAR: StringName = "2"


const RAW_FILE_SUB_TAGS: Array = [
	SubTag.ATLAS,
	SubTag.BOOK,
	SubTag.CUP,
	SubTag.ENCYCLOPEDIA,
	SubTag.FIELD_REPORT,
]
const SERVICE_SUB_TAGS: Array = [
	SubTag.GARAGE,
	SubTag.SALARY,
	SubTag.STATION,
]

const CHAR_TO_TAG: Dictionary = {
	WALL_CHAR: SubTag.WALL,
	DOOR_CHAR: SubTag.DOOR,
	SPECIAL_FLOOR_CHAR: SubTag.INTERNAL_FLOOR,
	PHONE_BOOTH_CHAR: SubTag.PHONE_BOOTH,
	SHELF_CHAR: SubTag.SHELF,

	CLERK_CHAR: SubTag.CLERK,
	OFFICER_CHAR: SubTag.OFFICER,
	DESK_CHAR: SubTag.DESK,
}


static func create_sprite() -> void:
	var tagged_sprites: Array = []
	var occupied_grids: Dictionary = Map2D.init_map(false)

	_create_floor(tagged_sprites)
	_create_from_file(occupied_grids, tagged_sprites)
	_create_pc(occupied_grids, tagged_sprites)
	_create_indicator(tagged_sprites)

	NodeHub.ref_SignalHub.sprite_created.emit(tagged_sprites)


static func _create_pc(
		occupied_grids: Dictionary, tagged_sprites: Array
) -> void:
	var coord: Vector2i = Vector2i.ZERO

	while true:
		coord.x = NodeHub.ref_RandomNumber.get_int(0, DungeonSize.MAX_X)
		coord.y = NodeHub.ref_RandomNumber.get_int(0, DungeonSize.MAX_Y)
		if not occupied_grids[coord.x][coord.y]:
			break

	tagged_sprites.push_back(SpriteFactory.create_actor(
			SubTag.PC, coord, false
	))


static func _create_floor(tagged_sprites: Array) -> void:
	for x: int in range(0, DungeonSize.MAX_X):
		for y: int in range(0, DungeonSize.MAX_Y):
			tagged_sprites.push_back(SpriteFactory.create_ground(
					SubTag.DUNGEON_FLOOR, Vector2i(x, y),
					false
			))


static func _create_indicator(tagged_sprites: Array) -> void:
	const SUB_TAGS: Array = [
		SubTag.INDICATOR_0, SubTag.INDICATOR_1, SubTag.INDICATOR_2,
		SubTag.INDICATOR_3, SubTag.INDICATOR_4, SubTag.INDICATOR_5,
		SubTag.INDICATOR_6, SubTag.INDICATOR_7, SubTag.INDICATOR_8,
		SubTag.INDICATOR_9,

		SubTag.INDICATOR_A, SubTag.INDICATOR_B, SubTag.INDICATOR_C,
		SubTag.INDICATOR_D, SubTag.INDICATOR_E, SubTag.INDICATOR_F,
		SubTag.INDICATOR_G, SubTag.INDICATOR_H, SubTag.INDICATOR_J,
		SubTag.INDICATOR_K, SubTag.INDICATOR_L
	]
	var coord: Vector2i = Vector2i(0, 0)
	var offset: Vector2i = Vector2i(0, 0)
	var t_sprite: TaggedSprite

	for x: int in range(0, DungeonSize.MAX_X):
		coord.x = x
		coord.y = 0
		offset.x = 0
		offset.y = -INDICATOR_OFFSET
		t_sprite = CreateSprite.create(
				MainTag.INDICATOR, SUB_TAGS[x], coord, offset
		)
		tagged_sprites.push_back(t_sprite)
		NodeHub.ref_DataHub.set_x_indicators(x, t_sprite.sprite)

		coord.y = DungeonSize.MAX_Y - 1
		offset.y = INDICATOR_OFFSET
		t_sprite = CreateSprite.create(
				MainTag.INDICATOR, SUB_TAGS[x], coord, offset
		)
		tagged_sprites.push_back(t_sprite)
		NodeHub.ref_DataHub.set_x_indicators(x, t_sprite.sprite)

	for y: int in range(0, DungeonSize.MAX_Y):
		coord.x = 0
		coord.y = y
		offset.x = -INDICATOR_OFFSET
		offset.y = 0
		t_sprite = CreateSprite.create(
				MainTag.INDICATOR, SUB_TAGS[y], coord, offset
		)
		tagged_sprites.push_back(t_sprite)
		NodeHub.ref_DataHub.set_y_indicators(y, t_sprite.sprite)


static func _create_arrow_indicator(
		coord: Vector2i, tagged_sprites: Array
) -> void:
	var indicators: Dictionary = {
		SubTag.INDICATOR_TOP: [
			Vector2i(coord.x, 0), Vector2i(0, -INDICATOR_OFFSET)
		],
		SubTag.INDICATOR_BOTTOM: [
			Vector2i(coord.x, DungeonSize.MAX_Y - 1),
			Vector2i(0, INDICATOR_OFFSET)
		],
		SubTag.INDICATOR_LEFT: [
			Vector2i(0, coord.y), Vector2i(-INDICATOR_OFFSET, 0)
		],
	}
	var new_coord: Vector2i
	var new_offset: Vector2i

	for i: StringName in indicators:
		new_coord = indicators[i][0]
		new_offset = indicators[i][1]
		tagged_sprites.push_back(CreateSprite.create(
				MainTag.INDICATOR, i, new_coord, new_offset
		))


# Create a sprite now:
#>> character, coord, occupied_grids, tagged_sprites
# Create a sprite later:
#>> coords_raw_a, coords_raw_b, coords_service_1, coords_service_2
static func _create_from_character(
		character: String, coord: Vector2i,
		occupied_grids: Dictionary, tagged_sprites: Array,
		coords_raw_a: Array, coords_raw_b: Array,
		coords_service_1: Array, coords_service_2: Array,
		coords_optional_wall: Array
) -> void:
	var t_sprite: TaggedSprite

	occupied_grids[coord.x][coord.y] = true
	match character:
		WALL_CHAR, DOOR_CHAR, DESK_CHAR, PHONE_BOOTH_CHAR:
			t_sprite = SpriteFactory.create_building(
					CHAR_TO_TAG[character], coord, false
			)
			tagged_sprites.push_back(t_sprite)

		SPECIAL_FLOOR_CHAR:
			t_sprite = SpriteFactory.create_ground(
					CHAR_TO_TAG[character], coord, false
			)
			t_sprite.sprite.z_index \
					= GameData.INTERNAL_FLOOR_Z_LAYER
			tagged_sprites.push_back(t_sprite)

		CLERK_CHAR, OFFICER_CHAR, SHELF_CHAR:
			t_sprite = SpriteFactory.create_actor(
					CHAR_TO_TAG[character], coord, false
			)
			tagged_sprites.push_back(t_sprite)

		RAW_FILE_A_CHAR:
			coords_raw_a.push_back(coord)

		RAW_FILE_B_CHAR:
			coords_raw_b.push_back(coord)

		SERVICE_1_CHAR:
			coords_service_1.push_back(coord)

		SERVICE_2_CHAR:
			coords_service_2.push_back(coord)

		OPTIONAL_WALL_CHAR:
			coords_optional_wall.push_back(coord)

		_:
			occupied_grids[coord.x][coord.y] = false


static func _get_transform_tags(
		prefab_index: int, transform_tags: Array
) -> Array:
	var tags: Array

	# Do not transform the first quarter.
	if prefab_index == 1:
		tags = []
	# Flip the second quarter twice to fit into the bottom left corner.
	elif prefab_index == 2:
		tags = [
			DungeonPrefab.FLIP_VERTICALLY,
			DungeonPrefab.FLIP_HORIZONTALLY,
		]
	# Transform two rooms randomly based on possible options.
	else:
		for i: int in transform_tags:
			if NodeHub.ref_RandomNumber.get_percent_chance(
					PERCENT_CHANCE
			):
				tags.push_back(i)
	return tags


static func _create_from_file(
		occupied_grids: Dictionary, tagged_sprites: Array
) -> void:
	var path_to_file: Array = _get_file_path(PATH_TO_ROOM, PATH_TO_QUARTER)

	var parsed_file: ParsedFile
	var transform_tags: Array
	var packed_prefab: PackedPrefab

	var coord: Vector2i = Vector2i(0, 0)
	# Two quarter blocks overlap each other. Therefore the top-right corner
	# of the second quarter block is ignored.
	# {y * 100 + x: true}
	var overlap_grids: Dictionary

	var coords_raw_a: Array
	var coords_raw_b: Array
	var coords_service_1: Array
	var coords_service_2: Array
	var coords_optional_wall: Array

	for i: int in range(0, path_to_file.size()):
		parsed_file = FileIo.read_as_line(path_to_file[i])
		transform_tags = _get_transform_tags(i, TRANSFORM_TAGS)
		packed_prefab = DungeonPrefab.get_prefab(
				parsed_file.output_line, transform_tags
		)
		_create_from_prefab(
				occupied_grids, tagged_sprites,
				i, packed_prefab, coord, overlap_grids,
				coords_raw_a, coords_raw_b,
				coords_service_1, coords_service_2,
				coords_optional_wall
		)

	_create_from_coord(
			tagged_sprites,
			coords_raw_a, coords_raw_b,
			coords_service_1, coords_service_2,
			coords_optional_wall
	)


static func _get_file_path(
		path_to_room: StringName, path_to_quarter: StringName
) -> Array:
	var rooms: Array = FileIo.get_files(path_to_room)
	var quarters: Array = FileIo.get_files(path_to_quarter)

	ArrayHelper.shuffle(rooms, NodeHub.ref_RandomNumber)
	ArrayHelper.shuffle(quarters, NodeHub.ref_RandomNumber)

	if DEBUG:
		for i: int in range(0, 2):
			print(rooms[i])
			print(quarters[i])

	return [
		rooms[0],
		quarters[0],
		quarters[1],
		rooms[1],
	]


static func _get_merged_coords(source_coords: Array, new_coords: Array) -> void:
	ArrayHelper.shuffle(new_coords, NodeHub.ref_RandomNumber)
	source_coords.push_back(new_coords.pop_back())
	ArrayHelper.shuffle(source_coords, NodeHub.ref_RandomNumber)


static func _get_halved_coords(source_coords: Array) -> void:
	ArrayHelper.shuffle(source_coords, NodeHub.ref_RandomNumber)
	source_coords.resize(floor(source_coords.size() * 0.5))


static func _get_appended_coords(
		source_coords: Array, coord_arrays: Array
) -> void:
	for i: Array in coord_arrays:
		source_coords.append_array(i)


static func _create_from_coord(
		tagged_sprites: Array,
		coords_raw_a: Array, coords_raw_b: Array,
		coords_service_1: Array, coords_service_2: Array,
		coords_optional_wall: Array
) -> void:
	var t_sprite: TaggedSprite
	var wall_coords: Array

	_get_merged_coords(coords_raw_a, coords_raw_b)
	_get_merged_coords(coords_service_1, coords_service_2)
	_get_halved_coords(coords_optional_wall)
	_get_appended_coords(wall_coords, [
		coords_optional_wall,
		coords_raw_b,
		coords_service_2,
	])

	for i: int in range(0, coords_raw_a.size()):
		t_sprite = SpriteFactory.create_actor(
				RAW_FILE_SUB_TAGS[i], coords_raw_a[i], false
		)
		tagged_sprites.push_back(t_sprite)

	for i: int in range(0, coords_service_1.size()):
		t_sprite = SpriteFactory.create_actor(
				SERVICE_SUB_TAGS[i], coords_service_1[i], false
		)
		tagged_sprites.push_back(t_sprite)

	for i: int in range(0, wall_coords.size()):
		t_sprite = SpriteFactory.create_building(
				SubTag.WALL, wall_coords[i], false
		)
		tagged_sprites.push_back(t_sprite)


static func _create_from_prefab(
		occupied_grids: Dictionary, tagged_sprites: Array,
		loop_index: int, packed_prefab: PackedPrefab, coord: Vector2i,
		overlap_grids: Dictionary,
		coords_raw_a: Array, coords_raw_b: Array,
		coords_service_1: Array, coords_service_2: Array,
		coords_optional_wall: Array
) -> void:
	# y * 100 + x
	var hashed_coord: int

	for x: int in range(0, packed_prefab.max_x):
		for y: int in range(0, packed_prefab.max_y):
			coord.x = x + INDEX_TO_START_COORD[loop_index].x
			coord.y = y + INDEX_TO_START_COORD[loop_index].y

			hashed_coord = 100 * coord.y + coord.x
			# Record coords in the first quarter block.
			if loop_index == 1:
				overlap_grids[hashed_coord] = true
			# Skip overlap area in the second quarter block.
			elif (
					(loop_index == 2)
					and overlap_grids.has(hashed_coord)
			):
				continue

			_create_from_character(
					packed_prefab.prefab[x][y], coord,
					occupied_grids, tagged_sprites,
					coords_raw_a, coords_raw_b,
					coords_service_1, coords_service_2,
					coords_optional_wall
			)

