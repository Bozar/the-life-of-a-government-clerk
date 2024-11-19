class_name GameProgress


enum {
    DRAFT_PILE_0, DRAFT_PILE_1, LEAK, DOOR,
}

const MAX_RETRY: int = 10


static func update_world(
        state: ProgressState, ref_PcAction: PcAction,
        ref_ActorAction: ActorAction, ref_RandomNumber: RandomNumber
        ) -> void:
    state.challenge_level = GameData.CHALLENGES_PER_DELIVERY.size() \
            - ref_PcAction.delivery
    state.max_trap = HandleServant.count_idlers(
            ref_ActorAction.get_actor_states(SubTag.SERVANT)
            )

    _init_ground_coords(state, ref_RandomNumber)
    _create_rand_sprite(
            MainTag.ACTOR, SubTag.SERVANT, state,
            ref_PcAction, ref_RandomNumber, MAX_RETRY
            )
    for i: int in GameData.CHALLENGES_PER_DELIVERY[state.challenge_level]:
        match i:
            DRAFT_PILE_0:
                state.max_trap = floor(state.max_trap * GameData.DRAFT_PILE_MOD)
                _create_rand_sprite(
                        MainTag.TRAP, SubTag.DRAFT_PILE, state,
                        ref_PcAction, ref_RandomNumber, MAX_RETRY
                        )
            DRAFT_PILE_1:
                _create_rand_sprite(
                        MainTag.TRAP, SubTag.DRAFT_PILE, state,
                        ref_PcAction, ref_RandomNumber, MAX_RETRY
                        )
            LEAK:
                HandleClerk.reduce_progress(
                        ref_ActorAction.get_actor_states(SubTag.CLERK),
                        ref_RandomNumber
                        )
            DOOR:
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

            for i: Sprite2D in sprites:
                if _is_invalid_sprite(i):
                    save_coord = false
                    break
            if save_coord:
                state.ground_coords.push_back(coord)

    ArrayHelper.shuffle(state.ground_coords, ref_RandomNumber)


static func _create_rand_sprite(
        main_tag: StringName, sub_tag: StringName, state: ProgressState,
        ref_PcAction: PcAction, ref_RandomNumber: RandomNumber, retry: int
        ) -> void:
    if retry < 1:
        return

    match main_tag:
        MainTag.ACTOR:
            if _has_max_actor(state.challenge_level, ref_PcAction):
                return
        MainTag.TRAP:
            if _has_max_trap(state.max_trap, sub_tag):
                return
        _:
            pass

    var coord: Vector2i = state.ground_coords[state.ground_index]
    var is_created: bool = false

    if _is_valid_coord(coord, ref_PcAction.pc_coord):
        SpriteFactory.create_sprite(main_tag, sub_tag, coord, true)
        is_created = true
    _update_ground_index(state, ref_RandomNumber)

    if not is_created:
        _create_rand_sprite(
                main_tag, sub_tag, state, ref_PcAction, ref_RandomNumber,
                retry - 1
                )


static func _has_max_actor(
        challenge_level: int, ref_PcAction: PcAction
        ) -> bool:
    var max_servant: int = GameData.BASE_SERVANT \
            + GameData.ADD_SERVANT * challenge_level
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


static func _has_max_trap(max_trap: int, sub_tag: StringName) -> bool:
    return SpriteState.get_sprites_by_sub_tag(sub_tag).size() >= max_trap


static func _is_valid_coord(check_coord: Vector2i, pc_coord: Vector2i) -> bool:
    if SpriteState.has_actor_at_coord(check_coord):
        return false
    elif SpriteState.has_trap_at_coord(check_coord):
        return false
    elif ConvertCoord.is_in_range(
            check_coord, pc_coord, GameData.MIN_DISTANCE_TO_PC
            ):
        return false
    return true


static func _update_ground_index(
        state: ProgressState, ref_RandomNumber: RandomNumber
        ) -> void:
    state.ground_index += 1
    if state.ground_index > state.ground_coords.size():
        state.ground_index = 0
        ArrayHelper.shuffle(state.ground_coords, ref_RandomNumber)
