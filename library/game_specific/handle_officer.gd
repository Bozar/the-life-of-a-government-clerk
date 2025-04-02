class_name HandleOfficer


static func can_receive_document(state: OfficerState) -> bool:
    return state.is_active


static func set_active(
        officer_states: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    var dup_states: Array
    var state: OfficerState
    var has_active_officer: bool = false

    dup_states = officer_states.duplicate()
    ArrayHelper.shuffle(dup_states, ref_RandomNumber)

    for i: int in range(0, dup_states.size()):
        state = dup_states[i]
        if state.repeat_counter > GameData.MAX_OFFICER_REPEAT:
            state.repeat_counter = 0
            state.is_active = false
        elif not has_active_officer:
            has_active_officer = true
            state.repeat_counter += 1
            state.is_active = true
        else:
            state.is_active = false

