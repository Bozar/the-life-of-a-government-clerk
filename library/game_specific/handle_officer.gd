class_name HandleOfficer


static func can_receive_document(state: OfficerState) -> bool:
    return state.is_active


static func set_active(states: Array, ref_RandomNumber: RandomNumber) \
        -> void:
    var dup_states: Array
    var state: OfficerState

    dup_states = states.duplicate()
    ArrayHelper.shuffle(dup_states, ref_RandomNumber)

    for i in range(0, dup_states.size()):
        state = dup_states[i]
        state.is_active = (i == 0)