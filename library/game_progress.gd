class_name GameProgress


enum {
    NONE, SERVANT, BOOK_PILE_0, BOOK_PILE_1, CLERK_0, CLERK_1,
}

const MAX_RETRY: int = 10


static func update_world(
        state: ProgressState, ref_PcAction: PcAction,
        ref_RandomNumber: RandomNumber
        ) -> void:
    state.challenge_level = GameData.CHALLENGES_PER_DELIVERY.size() \
            - ref_PcAction.delivery

    _init_ground_coords(state, ref_RandomNumber)
    for i: int in GameData.CHALLENGES_PER_DELIVERY[state.challenge_level]:
        match i:
            SERVANT:
                _create_servant(
                        state, ref_PcAction, ref_RandomNumber, MAX_RETRY
                        )
            BOOK_PILE_0:
                pass
            BOOK_PILE_1:
                pass
            CLERK_0:
                pass
            CLERK_1:
                pass
            _:
                continue


static func _init_ground_coords(
        state: ProgressState, ref_RandomNumber: RandomNumber
        ) -> void:
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

    ArrayHelper.shuffle(state.ground_coords, ref_RandomNumber)


static func _create_servant(
        state: ProgressState, ref_PcAction: PcAction,
        ref_RandomNumber: RandomNumber, retry: int
        ) -> void:
    if retry < 0:
        return
    elif (retry == MAX_RETRY) and _has_max_servant(
            state.challenge_level, ref_PcAction
            ):
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
        ArrayHelper.shuffle(state.ground_coords, ref_RandomNumber)

    if not is_created:
        _create_servant(state, ref_PcAction, ref_RandomNumber, retry - 1)


static func _has_max_servant(
        document_delivered: int, ref_PcAction: PcAction
        ) -> bool:
    var max_servant: int = GameData.BASE_SERVANT \
            + GameData.ADD_SERVANT * document_delivered
    var current_servant: int = SpriteState.get_sprites_by_sub_tag(
            SubTag.SERVANT
            ).size()
    var carry_servant: int = Cart.count_item(
            SubTag.SERVANT, ref_PcAction.pc, ref_PcAction.linked_cart_state
            )

    return current_servant + carry_servant >= max_servant


static func _is_invalid_sprite(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(SubTag.INTERNAL_FLOOR) \
            or sprite.is_in_group(MainTag.BUILDING) \
            or (sprite.is_in_group(MainTag.ACTOR)
            and (not sprite.is_in_group(SubTag.PC))
            )
