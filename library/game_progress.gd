class_name GameProgress


const MAX_RETRY: int = 10


static func update_world(
        ref_PcAction: PcAction, ref_ActorAction: ActorAction,
        ref_RandomNumber: RandomNumber
        ) -> void:
    var state: ProgressState = ref_PcAction.progress_state

    _init_ground_coords(state, ref_RandomNumber)

    # Create Servants. This challenge is available throughout the game.
    _create_rand_sprite(
            MainTag.ACTOR, SubTag.SERVANT, state,
            ref_PcAction, ref_ActorAction, ref_RandomNumber, MAX_RETRY
            )

    # Create traps.
    state.max_trap = min(
            ref_ActorAction.count_combined_idler, GameData.MAX_TRAP
            )
    _create_rand_sprite(
            MainTag.TRAP, SubTag.TRASH, state,
            ref_PcAction, ref_ActorAction, ref_RandomNumber, MAX_RETRY
            )

    # Reduce Clerk progress.
    if state.challenge_level >= GameData.MIN_LEVEL_LEAK:
        HandleClerk.reduce_progress(
                ref_ActorAction.get_actor_states(SubTag.CLERK), ref_RandomNumber
                )


static func update_turn_counter(ref_PcAction: PcAction) -> void:
    ref_PcAction.progress_state.turn_counter += 1


static func update_challenge_level(ref_PcAction: PcAction) -> void:
    ref_PcAction.progress_state.challenge_level += 1


static func update_phone(
        ref_PcAction: PcAction, ref_RandomNumber: RandomNumber
        ) -> void:
    var state: ProgressState = ref_PcAction.progress_state
    var max_phone: int = GameData.MAX_PHONE
    var phone_sprites: Array = SpriteState.get_sprites_by_sub_tag(SubTag.PHONE)
    var phone_coord: Vector2i

    _init_phone_coords(state, ref_RandomNumber)

    while max_phone > 0:
        _update_phone_index(state, ref_RandomNumber)
        phone_coord = state.phone_coords[state.phone_index]
        if SpriteState.has_actor_at_coord(phone_coord):
            continue
        SpriteFactory.create_actor(SubTag.PHONE, phone_coord, true)
        max_phone -= 1

    for i: Sprite2D in phone_sprites:
        SpriteFactory.remove_sprite(i)


static func update_raw_file(
        ref_ActorAction: ActorAction, ref_RandomNumber: RandomNumber
        ) -> void:
    var sprites: Array = ref_ActorAction.raw_file_sprites
    var states: Array = ref_ActorAction.raw_file_states

    _swap_sprites(sprites, ref_RandomNumber)
    for i in states:
        i.reset_progress_bar_coord()
    for i in SpriteState.get_sprites_by_sub_tag(SubTag.PROGRESS_BAR):
        SpriteFactory.remove_sprite(i)


static func update_service(
        ref_ActorAction: ActorAction, ref_RandomNumber: RandomNumber
        ) -> void:
    _swap_sprites(ref_ActorAction.service_sprites, ref_RandomNumber)


static func _swap_sprites(
        sprites: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    ArrayHelper.shuffle(sprites, ref_RandomNumber)
    for i in range(0, sprites.size() - 1):
        SpriteState.swap_sprite(sprites[i], sprites[i + 1])


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


static func _init_phone_coords(
        state: ProgressState, ref_RandomNumber: RandomNumber
        ) -> void:
    if not state.phone_coords.is_empty():
        return

    var special_wall_sprites: Array = SpriteState.get_sprites_by_sub_tag(
            SubTag.SPECIAL_WALL
            )

    for i: Sprite2D in special_wall_sprites:
        state.phone_coords.push_back(ConvertCoord.get_coord(i))
        i.remove_from_group(SubTag.SPECIAL_WALL)
    state.phone_index = -1
    ArrayHelper.shuffle(state.phone_coords, ref_RandomNumber)


static func _create_rand_sprite(
        main_tag: StringName, sub_tag: StringName, state: ProgressState,
        ref_PcAction: PcAction, ref_ActorAction: ActorAction,
        ref_RandomNumber: RandomNumber, retry: int
        ) -> void:
    if retry < 1:
        return

    match main_tag:
        MainTag.ACTOR:
            if _has_max_actor(ref_PcAction, ref_ActorAction):
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
                main_tag, sub_tag, state, ref_PcAction, ref_ActorAction,
                ref_RandomNumber, retry - 1
                )


static func _has_max_actor(
        ref_PcAction: PcAction, ref_ActorAction: ActorAction
        ) -> bool:
    var max_servant: int = GameData.BASE_SERVANT
    var occupied_shelf: int = HandleShelf.count_occupied_shelf(
            ref_ActorAction.shelf_states
            )
    var current_servant: int = SpriteState.get_sprites_by_sub_tag(
            SubTag.SERVANT
            ).size()
    var carry_servant: int = Cart.count_item(
            SubTag.SERVANT, ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    return current_servant + carry_servant >= max_servant \
            + occupied_shelf * GameData.SHELF_TO_SERVANT


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
    elif not ConvertCoord.is_in_range(
            check_coord, pc_coord, GameData.MAX_DISTANCE_TO_PC
            ):
        return false
    return true


static func _update_ground_index(
        state: ProgressState, ref_RandomNumber: RandomNumber
        ) -> void:
    state.ground_index += 1
    if state.ground_index < state.ground_coords.size():
        return
    state.ground_index = 0
    ArrayHelper.shuffle(state.ground_coords, ref_RandomNumber)


static func _update_phone_index(
            state: ProgressState, ref_RandomNumber: RandomNumber
            ) -> void:
        state.phone_index += 1
        if state.phone_index < state.phone_coords.size():
            return
        state.phone_index = 0
        ArrayHelper.shuffle(state.phone_coords, ref_RandomNumber)

