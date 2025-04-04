class_name HandleServant


static func update_idle_duration(state: ServantState) -> void:
    if state.is_active:
        return
    state.idle_duration += 1


static func reset_idle_duration(state: ServantState) -> void:
    state.idle_duration = 0


static func switch_examine_mode(is_enter: bool, servant_states: Array) -> void:
    var visual_tag: StringName

    for i: ServantState in servant_states:
        if is_enter:
            visual_tag = VisualTag.get_percent_tag(
                    i.idle_duration, i.max_idle_duration
                    )
            VisualEffect.switch_sprite(i.sprite, visual_tag)
        else:
            # Switch sprite implicitly.
            i.idle_duration = i.idle_duration


static func count_idle_servant(servant_states: Array) -> int:
    var counter: int = 0

    for i: ServantState in servant_states:
        if i.is_active:
            counter += 1
    return counter

