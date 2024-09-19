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
