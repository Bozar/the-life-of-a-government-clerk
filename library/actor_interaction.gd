class_name ActorInteraction


static func handle_input(pc: Sprite2D, actor: Sprite2D,
        pc_action: PcAction) -> void:
    var sub_tag: StringName = SpriteState.get_sub_tag(actor)

    match sub_tag:
        SubTag.SALARY:
            if not _get_cash(pc_action):
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
