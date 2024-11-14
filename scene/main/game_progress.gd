class_name GameProgress
extends Node2D


const MAX_RETRY: int = 10


signal game_over(player_win: bool)


var _progress_state := ProgressState.new()


func update_world(ref_PcAction: PcAction) -> void:
    _init_ground_coords(_progress_state)
    _create_servant(_progress_state, ref_PcAction, MAX_RETRY)


func _init_ground_coords(state: ProgressState) -> void:
    if not state.ground_coords.is_empty():
        return

    var coord: Vector2i = Vector2i(0, 0)
    var sprites: Array
    var save_coord: bool

    for x in range(0, DungeonSize.MAX_X):
        for y in range(0, DungeonSize.MAX_Y):
            coord.x = x
            coord.y = y
            sprites = SpriteState.get_sprites_by_coord(coord)
            save_coord = true

            for i in sprites:
                if _is_invalid_sprite(i):
                    save_coord = false
                    break
            if save_coord:
                state.ground_coords.push_back(coord)

    ArrayHelper.shuffle(state.ground_coords, NodeHub.ref_RandomNumber)


func _create_servant(
        state: ProgressState, ref_PcAction: PcAction, retry: int
        ) -> void:
    if retry < 0:
        return
    elif (retry == MAX_RETRY) and _has_max_servant(ref_PcAction):
        return

    var coord: Vector2i = state.ground_coords[state.ground_index]
    var is_created: bool = false

    if SpriteState.has_actor_at_coord(coord):
        pass
    elif ConvertCoord.is_in_range(coord, ref_PcAction.pc_coord,
            GameData.MIN_DISTANCE_TO_PC):
        pass
    else:
        SpriteFactory.create_actor(SubTag.SERVANT, coord, true)
        is_created = true

    state.ground_index += 1
    if state.ground_index > state.ground_coords.size():
        state.ground_index = 0
        ArrayHelper.shuffle(state.ground_coords, NodeHub.ref_RandomNumber)

    if not is_created:
        _create_servant(state, ref_PcAction, retry - 1)


func _has_max_servant(ref_PcAction: PcAction) -> bool:
    var remaining_delivery: int = GameData.MAX_DELIVERY - ref_PcAction.delivery
    var max_servant: int = GameData.BASE_SERVANT + \
            GameData.ADD_SERVANT * remaining_delivery
    var current_servant: int = SpriteState.get_sprites_by_sub_tag(
            SubTag.SERVANT).size()
    var carry_servant: int = ref_PcAction.count_item(SubTag.SERVANT)

    return current_servant + carry_servant >= max_servant


func _is_invalid_sprite(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(SubTag.INTERNAL_FLOOR) or \
            sprite.is_in_group(MainTag.BUILDING) or \
            (sprite.is_in_group(MainTag.ACTOR) and \
            not sprite.is_in_group(SubTag.PC))
