class_name PcHitActor


static func handle_input(actor: Sprite2D, ref_PcAction: PcAction,
        ref_ActorAction: ActorAction, ref_GameProgress: GameProgress) -> void:
    var sub_tag: StringName = SpriteState.get_sub_tag(actor)
    var service_type: int

    match sub_tag:
        SubTag.SALARY:
            if not _get_cash(ref_PcAction):
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
        _:
            return

    ScheduleHelper.start_next_turn()


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
    ref_PcAction.account += GameData.INCOME_DOCUMENT
    ref_PcAction.delivery -= 1
    return true