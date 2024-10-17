class_name HandleServant


static func update_idle_duration(state: ServantState) -> void:
    if state.is_active:
        return
    state.idle_duration += 1


static func switch_examine_mode(is_examine: bool, states: Array) -> void:
    var state: ServantState
    var visual_tag: StringName

    for i in states:
        state = i
        if is_examine:
            visual_tag = VisualTag.get_percent_tag(state.idle_duration,
                    state.max_idle_duration)
            VisualEffect.switch_sprite(state.sprite, visual_tag)
        else:
            # Switch sprite implicitly.
            state.idle_duration = state.idle_duration


static func get_servant_cooldown(states: Array) -> int:
    var state: ServantState
    var cooldown: int = 0

    for i in states:
        state = i
        if state.is_active:
            cooldown += GameData.SERVANT_ADD_COOLDOWN
    return cooldown
