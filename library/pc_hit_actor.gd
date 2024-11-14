class_name PcHitActor


static func handle_input(
        actor: Sprite2D, ref_PcAction: PcAction, ref_ActorAction: ActorAction,
        ref_GameProgress: GameProgress
        ) -> void:
    var sub_tag: StringName = SpriteState.get_sub_tag(actor)
    var player_win: bool
    var first_item_tag: StringName

    match sub_tag:
        SubTag.SALARY:
            player_win = ref_PcAction.delivery < 1
            if _get_cash(ref_PcAction) or player_win:
                pass
            else:
                return
        SubTag.GARAGE:
            if not _use_garage(ref_PcAction):
                return
        SubTag.STATION:
            if not _clean_cart(ref_PcAction):
                return
        SubTag.SERVANT:
            if _load_servant(actor, ref_PcAction):
                pass
            else:
                # Order matters. The Servant may be removed by _push_servant().
                ref_ActorAction.push_servant(actor)
                _push_servant(actor, ref_PcAction)
        SubTag.OFFICER:
            if _remove_all_servant(ref_PcAction):
                pass
            elif ref_ActorAction.can_receive_document(actor) and \
                    _unload_document(ref_PcAction):
                ref_ActorAction.receive_document()
            else:
                return
        SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
            if _load_raw_file(actor, ref_PcAction, ref_ActorAction):
                ref_ActorAction.send_raw_file(actor)
            elif _can_unload_servant(actor, ref_PcAction) and \
                    ref_ActorAction.can_receive_servant(actor):
                _unload_servant(ref_PcAction)
                ref_ActorAction.receive_servant(actor)
            else:
                return
        SubTag.CLERK:
            if _remove_all_servant(ref_PcAction):
                pass
            else:
                first_item_tag = _get_first_item_tag(ref_PcAction)
                if _can_load_document(ref_PcAction) and \
                        ref_ActorAction.send_document(actor):
                    _load_document(ref_PcAction)
                elif _can_unload_raw_file(ref_PcAction) and \
                        ref_ActorAction.receive_raw_file(actor, first_item_tag):
                    _unload_raw_file(ref_PcAction)
                else:
                    return
        _:
            return

    if player_win:
        ref_GameProgress.game_over.emit(true)
    else:
        ScheduleHelper.start_next_turn()


static func _get_cash(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.account > 0:
        ref_PcAction.cash += ref_PcAction.account
        ref_PcAction.account = 0
        return true
    return false


static func _use_garage(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.delivery < 1:
        return false
    elif ref_PcAction.cash < 1:
        return false

    ref_PcAction.add_cart(GameData.ADD_CART)
    ref_PcAction.cash -= GameData.PAYMENT_GARAGE
    return true


static func _clean_cart(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.cash < 1:
        return false
    elif not ref_PcAction.clean_cart():
        return false
    ref_PcAction.cash -= GameData.PAYMENT_CLEAN
    return true


static func _push_servant(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    var actor_coord: Vector2i = ConvertCoord.get_coord(actor)
    var pc_coord: Vector2i = ref_PcAction.pc_coord
    var new_actor_coord: Vector2i
    var add_delay: int

    if ref_PcAction.count_cart() < GameData.CART_LENGTH_SHORT:
        ref_PcAction.delay = 0
    else:
        add_delay = floor(ref_PcAction.get_full_load_amount() *
                GameData.LOAD_AMOUNT_MULTIPLER  / GameData.MAX_LOAD_PER_CART)
        ref_PcAction.delay = GameData.BASE_DELAY + add_delay

    new_actor_coord = ConvertCoord.get_mirror_coord(pc_coord, actor_coord)
    if _is_valid_coord(new_actor_coord):
        SpriteState.move_sprite(actor, new_actor_coord)
    else:
        SpriteFactory.remove_sprite(actor)
    ref_PcAction.pull_cart(actor_coord)


static func _is_valid_coord(coord: Vector2i) -> bool:
    return DungeonSize.is_in_dungeon(coord) and \
            (not SpriteState.has_building_at_coord(coord)) and \
            (not SpriteState.has_actor_at_coord(coord))


static func _unload_document(ref_PcAction: PcAction) -> bool:
    var cart_sprite: Sprite2D = ref_PcAction.get_first_item()
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = ref_PcAction.get_state(cart_sprite)
    if cart_state.item_tag != SubTag.DOCUMENT:
        return false

    cart_state.item_tag = SubTag.CART
    # PC can still unload document after reaching the final goal (deliver 10
    # documents), but has no profit in return.
    if ref_PcAction.delivery > 0:
        ref_PcAction.account += GameData.INCOME_DOCUMENT
        ref_PcAction.delivery -= 1
    return true


static func _load_raw_file(actor: Sprite2D, ref_PcAction: PcAction,
        ref_ActorAction: ActorAction) -> bool:

    if not ref_ActorAction.raw_file_is_available(actor):
        return false
    elif actor.is_in_group(SubTag.ENCYCLOPEDIA) and not _is_long_cart(
            ref_PcAction):
        return false

    var cart: Sprite2D = ref_PcAction.get_last_slot()
    var state: CartState
    var sub_tag: StringName

    if cart == null:
        return false

    state = ref_PcAction.get_state(cart)
    sub_tag = SpriteState.get_sub_tag(actor)
    state.item_tag = sub_tag
    return true


static func _can_load_document(ref_PcAction: PcAction) -> bool:
    return ref_PcAction.get_last_slot() != null


static func _load_document(ref_PcAction: PcAction) -> void:
    var sprite: Sprite2D =  ref_PcAction.get_last_slot()
    var state: CartState = ref_PcAction.get_state(sprite)

    state.item_tag = SubTag.DOCUMENT


static func _can_unload_raw_file(ref_PcAction: PcAction) -> bool:
    var sprite: Sprite2D =  ref_PcAction.get_first_item()
    var state: CartState

    if sprite == null:
        return false

    state = ref_PcAction.get_state(sprite)
    return state.item_tag != SubTag.DOCUMENT


static func _unload_raw_file(ref_PcAction: PcAction) -> void:
    var sprite: Sprite2D =  ref_PcAction.get_first_item()
    var state: CartState = ref_PcAction.get_state(sprite)

    state.item_tag = SubTag.CART


static func _get_first_item_tag(ref_PcAction: PcAction) -> StringName:
    var sprite: Sprite2D =  ref_PcAction.get_first_item()
    var state: CartState

    if sprite == null:
        return SubTag.CART
    state = ref_PcAction.get_state(sprite)
    return state.item_tag


static func _load_servant(actor: Sprite2D, ref_PcAction: PcAction) -> bool:
    if ref_PcAction.count_cart() < GameData.CART_LENGTH_SHORT:
        return false

    var sprite: Sprite2D = ref_PcAction.get_last_slot()
    var state: CartState

    if sprite == null:
        return false

    state = ref_PcAction.get_state(sprite)
    state.item_tag = SubTag.SERVANT

    SpriteFactory.remove_sprite(actor)
    ref_PcAction.pull_cart(ConvertCoord.get_coord(actor))
    return true


static func _remove_all_servant(ref_PcAction: PcAction) -> bool:
    return ref_PcAction.remove_all_item(SubTag.SERVANT)


static func _can_unload_servant(
        actor: Sprite2D, ref_PcAction: PcAction
        ) -> bool:
    var cart_sprite: Sprite2D = ref_PcAction.get_first_item()
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = ref_PcAction.get_state(cart_sprite)
    if cart_state.item_tag != SubTag.SERVANT:
        return false

    if actor.is_in_group(SubTag.ENCYCLOPEDIA):
        return _is_long_cart(ref_PcAction)
    return true


static func _unload_servant(ref_PcAction: PcAction) -> void:
        var cart_sprite: Sprite2D = ref_PcAction.get_first_item()
        var cart_state: CartState = ref_PcAction.get_state(cart_sprite)

        cart_state.item_tag = SubTag.CART


static func _is_long_cart(ref_PcAction: PcAction) -> bool:
    return ref_PcAction.count_cart() >= GameData.CART_LENGTH_LONG
