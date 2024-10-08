class_name PcHitActor


static func handle_input(actor: Sprite2D, ref_PcAction: PcAction,
        ref_ActorAction: ActorAction, ref_GameProgress: GameProgress) -> void:
    var sub_tag: StringName = SpriteState.get_sub_tag(actor)
    var service_type: int
    var player_win: bool = false
    var first_item_tag: StringName

    match sub_tag:
        SubTag.SALARY:
            player_win = _player_win(ref_PcAction)
            if _get_cash(ref_PcAction) or player_win:
                pass
            else:
                return
        SubTag.SERVICE:
            service_type = ref_ActorAction.get_service_type(actor)
            # Change PC state.
            if _use_service(ref_PcAction, service_type):
                # Change actor state.
                ref_ActorAction.use_service(actor)
            else:
                return
        SubTag.STATION:
            if not _clean_cart(ref_PcAction):
                return
        SubTag.SERVANT:
            _hit_servant(actor, ref_PcAction)
        SubTag.OFFICER:
            if _unload_document(ref_PcAction):
                ref_ActorAction.receive_document()
            else:
                return
        SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
            if _load_raw_file(actor, ref_PcAction, ref_ActorAction):
                ref_ActorAction.send_raw_file(actor)
            else:
                return
        SubTag.CLERK:
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


static func switch_encyclopedia_sprite(ref_PcAction: PcAction,
        ref_ActorAction: ActorAction) -> void:
    var visual_tag: StringName

    for i in SpriteState.get_sprites_by_sub_tag(SubTag.ENCYCLOPEDIA):
        if (ref_PcAction.count_cart() < GameData.CART_LENGTH_LONG) or \
                (not ref_ActorAction.raw_file_is_available(i)):
            visual_tag = VisualTag.PASSIVE
        else:
            visual_tag = VisualTag.DEFAULT
        VisualEffect.switch_sprite(i, visual_tag)


static func _get_cash(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.account > 0:
        ref_PcAction.cash += ref_PcAction.account
        ref_PcAction.account = 0
        return true
    return false


static func _use_service(ref_PcAction: PcAction, service_type: int) -> bool:
    if service_type == ServiceState.NO_SERVICE:
        return false

    match service_type:
        ServiceState.CART:
            if ref_PcAction.cash < 1:
                return false
            ref_PcAction.add_cart(GameData.ADD_CART)
            ref_PcAction.cash -= GameData.PAYMENT_SERVICE
        ServiceState.ORDER:
            if ref_PcAction.delivery < 1:
                return false
            ref_PcAction.delivery -= 1
            ref_PcAction.cash += GameData.INCOME_ORDER
        ServiceState.STICK:
            if ref_PcAction.cash < 1:
                return false
            elif ref_PcAction.has_stick:
                return false
            ref_PcAction.has_stick = true
            ref_PcAction.cash -= GameData.PAYMENT_SERVICE
    return true


static func _clean_cart(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.cash < 1:
        return false
    elif not ref_PcAction.clean_cart():
        return false
    ref_PcAction.cash -= GameData.PAYMENT_CLEAN
    return true


static func _hit_servant(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    var coord: Vector2i = ConvertCoord.get_coord(actor)

    if ref_PcAction.count_cart() < GameData.CART_LENGTH_SHORT:
        ref_PcAction.delay = 0
    elif ref_PcAction.has_stick:
        ref_PcAction.delay = 0
    # TODO: Make it more punishing. Take load factor into account.
    else:
        ref_PcAction.delay = GameData.BASE_DELAY

    SpriteFactory.remove_sprite(actor)
    ref_PcAction.pull_cart(coord)


static func _unload_document(ref_PcAction: PcAction) -> bool:
    var cart_sprite: Sprite2D = ref_PcAction.get_first_item()
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = ref_PcAction.get_state(cart_sprite)
    if cart_state.item_tag != SubTag.DOCUMENT:
        return false

    cart_state.item_tag = SubTag.CART
    # PC loses a stick (if he has one) after unloading a document.
    ref_PcAction.has_stick = false
    # PC can still unload document after reaching the final goal (deliver 10
    # documents), but has no profit in return.
    if ref_PcAction.delivery > 0:
        ref_PcAction.account += GameData.INCOME_DOCUMENT
        ref_PcAction.delivery -= 1
    return true


static func _player_win(ref_PcAction: PcAction) -> bool:
    return (ref_PcAction.delivery < 1) and (not ref_PcAction.has_full_cart())


static func _load_raw_file(actor: Sprite2D, ref_PcAction: PcAction,
        ref_ActorAction: ActorAction) -> bool:
    if not ref_ActorAction.raw_file_is_available(actor):
        return false
    elif actor.is_in_group(SubTag.ENCYCLOPEDIA) and \
            (ref_PcAction.count_cart() < GameData.CART_LENGTH_LONG):
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
