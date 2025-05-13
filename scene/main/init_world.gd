class_name InitWorld
extends Node2D


const INDICATOR_OFFSET: int = 32

const PATH_TO_PREFAB: StringName = "res://resource/dungeon_prefab/"
const MAX_PREFABS_PER_ROW: int = 3
const MAX_PREFABS: int = 9
const EDIT_TAGS: Array = [
    DungeonPrefab.FLIP_VERTICALLY, DungeonPrefab.FLIP_HORIZONTALLY,
]

const INDEX_TO_START_COORD: Dictionary = {
    0: Vector2i(1, 1),
    1: Vector2i(7, 0),
    2: Vector2i(0, 6),
    3: Vector2i(14, 9),
}


const WALL_CHAR: StringName = "#"
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


func create_world() -> void:
    var tagged_sprites: Array = []
    var occupied_grids: Dictionary = Map2D.init_map(false)
    # {y * 100 + x: true}
    var overlap_grids: Dictionary
    var pc_coord: Vector2i

    _create_floor(tagged_sprites)
    _test_block(occupied_grids, tagged_sprites, overlap_grids)
    pc_coord = _create_pc(occupied_grids, tagged_sprites)
    _create_indicator(pc_coord, tagged_sprites)

    NodeHub.ref_SignalHub.sprite_created.emit(tagged_sprites)


func _create_pc(occupied_grids: Dictionary, tagged_sprites: Array) -> Vector2i:
    var coord: Vector2i = Vector2i.ZERO

    while true:
        coord.x = NodeHub.ref_RandomNumber.get_int(0, DungeonSize.MAX_X)
        coord.y = NodeHub.ref_RandomNumber.get_int(0, DungeonSize.MAX_Y)
        if not occupied_grids[coord.x][coord.y]:
            break

    tagged_sprites.push_back(SpriteFactory.create_actor(
            SubTag.PC, coord, false
            ))
    return coord


func _create_floor(tagged_sprites: Array) -> void:
    for x: int in range(0, DungeonSize.MAX_X):
        for y: int in range(0, DungeonSize.MAX_Y):
            tagged_sprites.push_back(SpriteFactory.create_ground(
                    SubTag.DUNGEON_FLOOR, Vector2i(x, y), false
                    ))


func _create_indicator(coord: Vector2i, tagged_sprites: Array) -> void:
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


func _create_from_character(
        character: String, coord: Vector2i,
        occupied_grids: Dictionary, tagged_sprites: Array,
        coords_raw_a: Array, coords_raw_b: Array,
        coords_service_1: Array, coords_service_2: Array
) -> void:
    var save_tagged_sprite: TaggedSprite

    occupied_grids[coord.x][coord.y] = true
    match character:
        WALL_CHAR, DOOR_CHAR, DESK_CHAR:
            save_tagged_sprite = SpriteFactory.create_building(
                    CHAR_TO_TAG[character], coord, false
                    )
            tagged_sprites.push_back(save_tagged_sprite)

        SPECIAL_FLOOR_CHAR:
            save_tagged_sprite = SpriteFactory.create_ground(
                    CHAR_TO_TAG[character], coord, false
                    )
            save_tagged_sprite.sprite.z_index = GameData.INTERNAL_FLOOR_Z_LAYER
            tagged_sprites.push_back(save_tagged_sprite)

        PHONE_BOOTH_CHAR:
            save_tagged_sprite = SpriteFactory.create_building(
                    CHAR_TO_TAG[character], coord, false
                    )
            tagged_sprites.push_back(save_tagged_sprite)

        CLERK_CHAR, OFFICER_CHAR, SHELF_CHAR:
            save_tagged_sprite = SpriteFactory.create_actor(
                    CHAR_TO_TAG[character], coord, false
                    )
            tagged_sprites.push_back(save_tagged_sprite)

        RAW_FILE_A_CHAR:
            coords_raw_a.push_back(coord)

        RAW_FILE_B_CHAR:
            if coord.x < DungeonSize.CENTER_X:
                coords_raw_b.push_back(coord)

        SERVICE_1_CHAR:
            coords_service_1.push_back(coord)

        SERVICE_2_CHAR:
            coords_service_2.push_back(coord)

        _:
            occupied_grids[coord.x][coord.y] = false


func _get_edit_tags(edit_tags: Array) -> Array:
    var tags: Array = []

    for i: int in edit_tags:
        if NodeHub.ref_RandomNumber.get_percent_chance(50):
            tags.push_back(i)
    return tags


func _test_block(
        occupied_grids: Dictionary, tagged_sprites: Array,
        overlap_grids: Dictionary
) -> void:
    const PATH_TO_FILE: Array = [
        "res://resource/dungeon_prefab/aa1.txt",
        "res://resource/dungeon_prefab/quarter.txt",
        "res://resource/dungeon_prefab/quarter.txt",
        "res://resource/dungeon_prefab/aa2.txt",
    ]
    var parsed_file: ParsedFile
    var packed_prefab: PackedPrefab
    var coord: Vector2i = Vector2i(0, 0)
    var hashed_coord: int
    var transforms: Array = [
        DungeonPrefab.DO_NOT_TRANSFORM, DungeonPrefab.DO_NOT_TRANSFORM
    ]
    var coords_raw_a: Array
    var coords_raw_b: Array
    var coords_service_1: Array
    var coords_service_2: Array
    var save_tagged_sprite: TaggedSprite

    for i: int in range(0, PATH_TO_FILE.size()):
        parsed_file = FileIo.read_as_line(PATH_TO_FILE[i])
        if i == 2:
            transforms[0] = DungeonPrefab.FLIP_HORIZONTALLY
            transforms[1] = DungeonPrefab.FLIP_VERTICALLY
        else:
            transforms[0] = DungeonPrefab.DO_NOT_TRANSFORM
            transforms[1] = DungeonPrefab.DO_NOT_TRANSFORM
        packed_prefab = DungeonPrefab.get_prefab(
                parsed_file.output_line, transforms
        )
        for x: int in range(0, packed_prefab.max_x):
            for y: int in range(0, packed_prefab.max_y):
                coord.x = x + INDEX_TO_START_COORD[i].x
                coord.y = y + INDEX_TO_START_COORD[i].y
                hashed_coord = 100 * coord.y + coord.x
                if i == 1:
                    overlap_grids[hashed_coord] = true
                elif (i == 2) and overlap_grids.has(hashed_coord):
                    continue
                _create_from_character(
                        packed_prefab.prefab[x][y], coord,
                        occupied_grids, tagged_sprites,
                        coords_raw_a, coords_raw_b,
                        coords_service_1, coords_service_2
                )

    #ArrayHelper.shuffle(coords_raw_b, NodeHub.ref_RandomNumber)
    ArrayHelper.shuffle(coords_service_2, NodeHub.ref_RandomNumber)

    coords_raw_a.push_back(coords_raw_b.pop_back())
    coords_service_1.push_back(coords_service_2.pop_back())

    ArrayHelper.shuffle(coords_raw_a, NodeHub.ref_RandomNumber)
    ArrayHelper.shuffle(coords_service_1, NodeHub.ref_RandomNumber)

    for i: int in range(0, coords_raw_a.size()):
        save_tagged_sprite = SpriteFactory.create_actor(
                RAW_FILE_SUB_TAGS[i], coords_raw_a[i], false
        )
        tagged_sprites.push_back(save_tagged_sprite)

    for i: int in range(0, coords_service_1.size()):
        save_tagged_sprite = SpriteFactory.create_actor(
                SERVICE_SUB_TAGS[i], coords_service_1[i], false
        )
        tagged_sprites.push_back(save_tagged_sprite)

