class_name ActorInteraction


static func handle_input(actor: Sprite2D, pc_action: PcAction,
        actor_action: ActorAction) -> void:
    var sub_tag: StringName = SpriteState.get_sub_tag(actor)

    match sub_tag:
        SubTag.SALARY:
            if not _get_cash(pc_action):
                return
        SubTag.SERVICE:
            # Change PC state.
            if _use_service(pc_action, actor_action.get_service_type(actor)):
                # Change actor state.
                actor_action.use_service(actor)
            else:
                return
        SubTag.STATION:
            if not _clean_cart(pc_action):
                return
        SubTag.SERVANT:
            _hit_servant(actor, pc_action)
        _:
            return
    ScheduleHelper.start_next_turn()


static func _get_cash(pc_action: PcAction) -> bool:
    if pc_action.account > 0:
        pc_action.cash += pc_action.account
        pc_action.account = 0
        return true
    return false


static func _use_service(pc_action: PcAction, service_type: int) -> bool:
    if service_type == ServiceState.NO_SERVICE:
        return false

    match service_type:
        ServiceState.CART:
            if pc_action.cash < 1:
                return false
            pc_action.add_cart(GameData.ADD_CART)
            pc_action.cash -= GameData.PAYMENT_SERVICE
        ServiceState.ORDER:
            if pc_action.delivery < 1:
                return false
            pc_action.delivery -= 1
            pc_action.cash += GameData.INCOME_ORDER
        ServiceState.STICK:
            if pc_action.cash < 1:
                return false
            elif pc_action.has_stick:
                return false
            pc_action.has_stick = true
            pc_action.cash -= GameData.PAYMENT_SERVICE
    return true


static func _clean_cart(pc_action: PcAction) -> bool:
    if pc_action.cash < 1:
        return false
    elif not pc_action.clean_cart():
        return false
    pc_action.cash -= GameData.PAYMENT_CLEAN
    return true


static func _hit_servant(actor: Sprite2D, pc_action: PcAction) -> void:
    var coord: Vector2i = ConvertCoord.get_coord(actor)

    if pc_action.count_cart() < GameData.CART_LENGTH_SHORT:
        pc_action.delay = 0
    elif pc_action.has_stick:
        pc_action.delay = 0
    # TODO: Make it more punishing. Take load factor into account.
    else:
        pc_action.delay = GameData.BASE_DELAY

    SpriteFactory.remove_sprite(actor)
    pc_action.pull_cart(coord)
