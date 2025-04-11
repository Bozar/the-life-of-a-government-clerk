class_name GameProgress


const MAX_RETRY: int = 10


static func update_world(
        ref_DataHub: DataHub, ref_ActorAction: ActorAction,
        ref_RandomNumber: RandomNumber
        ) -> void:
    _init_ground_coords(ref_DataHub, ref_RandomNumber)

    # Create Servants. This challenge is available throughout the game.
    _create_rand_sprite(
            MainTag.ACTOR, SubTag.SERVANT, ref_DataHub, ref_RandomNumber,
            MAX_RETRY
            )

    # Create Trashes.
    ref_DataHub.max_trap = ref_DataHub.count_idler \
            * (ref_DataHub.challenge_level + GameData.HIGH_LEVEL_MOD)
    _create_rand_sprite(
            MainTag.TRAP, SubTag.TRASH, ref_DataHub, ref_RandomNumber,
            MAX_RETRY
            )

    # Reduce Clerk progress.
    if ref_DataHub.challenge_level >= GameData.MIN_LEVEL_LEAK:
        HandleClerk.reduce_progress(
                ref_ActorAction.get_actor_states(SubTag.CLERK), ref_RandomNumber
                )

    # Create Phones.
    # {cash: max_phone}: {-1: 3, 0: 2, 1: 1, 2: 0, 3: -1, ...}
    ref_DataHub.max_phone = GameData.DEFAULT_PHONE - ref_DataHub.cash
    ref_DataHub.max_phone = max(GameData.MIN_PHONE, ref_DataHub.max_phone)
    ref_DataHub.max_phone = min(GameData.MAX_PHONE, ref_DataHub.max_phone)
    ref_DataHub.max_phone -= ref_DataHub.incoming_call
    if (ref_DataHub.max_phone > 0) \
            and (not _has_document(ref_DataHub)) \
            and (not _is_safe_load_amount_percent(ref_DataHub)):
        _create_rand_phone(ref_DataHub, ref_RandomNumber)


static func update_turn_counter(ref_DataHub: DataHub) -> void:
    ref_DataHub.turn_counter += 1


static func update_challenge_level(ref_DataHub: DataHub) -> void:
    ref_DataHub.challenge_level += 1


static func update_raw_file(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    var sprites: Array = ref_DataHub.raw_file_sprites
    var states: Array = ref_DataHub.raw_file_states

    _swap_sprites(sprites, ref_RandomNumber)
    for i in states:
        i.reset_progress_bar_coord()
    for i in SpriteState.get_sprites_by_sub_tag(SubTag.PROGRESS_BAR):
        SpriteFactory.remove_sprite(i)


static func update_service(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    _swap_sprites(ref_DataHub.service_sprites, ref_RandomNumber)


static func _swap_sprites(
        sprites: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    ArrayHelper.shuffle(sprites, ref_RandomNumber)
    for i in range(0, sprites.size() - 1):
        SpriteState.swap_sprite(sprites[i], sprites[i + 1])


static func _init_ground_coords(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    if not ref_DataHub.ground_coords.is_empty():
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
                ref_DataHub.set_ground_coords(coord)

    ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _init_phone_coords(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    if not ref_DataHub.phone_coords.is_empty():
        return

    for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(SubTag.PHONE_BOOTH):
        ref_DataHub.set_phone_coords(ConvertCoord.get_coord(i))
    ref_DataHub.phone_index = -1
    ArrayHelper.shuffle(ref_DataHub.phone_coords, ref_RandomNumber)


static func _create_rand_sprite(
        main_tag: StringName, sub_tag: StringName, ref_DataHub: DataHub,
        ref_RandomNumber: RandomNumber, retry: int
        ) -> void:
    if retry < 1:
        return
    elif not _is_valid_turn(ref_DataHub.turn_counter, main_tag):
        return

    match main_tag:
        MainTag.ACTOR:
            if _has_max_actor(ref_DataHub):
                return
        MainTag.TRAP:
            if _has_max_trap(ref_DataHub):
                return
        _:
            pass

    var coord: Vector2i = ref_DataHub.ground_coords[ref_DataHub.ground_index]
    var is_created: bool = false

    if _is_valid_coord(coord, ref_DataHub.pc_coord):
        if _can_create_empty_cart(ref_DataHub, ref_RandomNumber):
            SpriteFactory.create_actor(SubTag.EMPTY_CART, coord, true)
        else:
            SpriteFactory.create_sprite(main_tag, sub_tag, coord, true)
        is_created = true
    _update_ground_index(ref_DataHub, ref_RandomNumber)

    if not is_created:
        _create_rand_sprite(
                main_tag, sub_tag, ref_DataHub, ref_RandomNumber, retry - 1
                )


static func _create_rand_phone(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    var phone_coord: Vector2i
    var max_retry: int = MAX_RETRY

    _init_phone_coords(ref_DataHub, ref_RandomNumber)

    while (ref_DataHub.max_phone > 0) and (max_retry > 0):
        max_retry -= 1
        _update_phone_index(ref_DataHub, ref_RandomNumber)
        phone_coord = ref_DataHub.phone_coords[ref_DataHub.phone_index]

        if SpriteState.has_actor_at_coord(phone_coord):
            continue
        elif not _is_valid_coord(phone_coord, ref_DataHub.pc_coord):
            continue
        SpriteFactory.create_actor(SubTag.PHONE, phone_coord, true)
        ref_DataHub.max_phone -= 1


static func _has_max_actor(ref_DataHub: DataHub) -> bool:
    var max_servant: int = GameData.BASE_SERVANT
    var occupied_shelf: int = HandleShelf.count_occupied_shelf(
            ref_DataHub.shelf_states
            )
    var current_servant: int = ref_DataHub.count_servant
    var carry_servant: int = Cart.count_item(
            SubTag.SERVANT, ref_DataHub.pc, ref_DataHub.linked_cart_state
            )
    return current_servant + carry_servant >= max_servant \
            + occupied_shelf * GameData.SHELF_TO_SERVANT


static func _is_invalid_sprite(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(SubTag.INTERNAL_FLOOR) \
            or sprite.is_in_group(MainTag.BUILDING) \
            or (sprite.is_in_group(MainTag.ACTOR)
            and (not sprite.is_in_group(SubTag.PC))
            )


static func _is_valid_turn(turn_counter: int, main_tag: StringName) -> bool:
    var turn_interval: int

    match main_tag:
        MainTag.ACTOR:
            turn_interval = GameData.NEW_ACTOR_INTERVAL
        MainTag.TRAP:
            turn_interval = GameData.NEW_TRAP_INTERVAL
        _:
            return false
    return turn_counter % turn_interval == 0


static func _has_max_trap(ref_DataHub: DataHub) -> bool:
    return ref_DataHub.count_trash + ref_DataHub.count_empty_cart \
            >= ref_DataHub.max_trap


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
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    ref_DataHub.ground_index += 1
    if ref_DataHub.ground_index < ref_DataHub.ground_coords.size():
        return
    ref_DataHub.ground_index = 0
    ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _update_phone_index(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> void:
    ref_DataHub.phone_index += 1
    if ref_DataHub.phone_index < ref_DataHub.phone_coords.size():
        return
    ref_DataHub.phone_index = 0
    ArrayHelper.shuffle(ref_DataHub.phone_coords, ref_RandomNumber)


static func _has_document(ref_DataHub: DataHub) -> bool:
    var cart_sprite: Sprite2D = Cart.get_first_item(
            ref_DataHub.pc, ref_DataHub.linked_cart_state
            )
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = Cart.get_state(
            cart_sprite, ref_DataHub.linked_cart_state
            )
    return cart_state.item_tag == SubTag.DOCUMENT


static func _is_safe_load_amount_percent(ref_DataHub: DataHub) -> bool:
    var full_load: int = Cart.get_full_load_amount(
            ref_DataHub.pc, ref_DataHub.linked_cart_state
            )
    var count_cart: int = Cart.count_cart(ref_DataHub.linked_cart_state)
    var max_load: int = GameData.MAX_LOAD_PER_CART * count_cart
    var load_percent: float = full_load * 1.0 / max_load
    return load_percent <= GameData.SAFE_LOAD_AMOUT_PERCENT


static func _can_create_empty_cart(
        ref_DataHub: DataHub, ref_RandomNumber: RandomNumber
        ) -> bool:
    return ref_RandomNumber.get_percent_chance(GameData.ADD_EMPTY_CART_CHANCE) \
            and (Cart.count_cart(ref_DataHub.linked_cart_state) \
                    >= GameData.CART_LENGTH_SHORT) \
            and (not _is_safe_load_amount_percent(ref_DataHub))

