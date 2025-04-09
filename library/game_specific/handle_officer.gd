class_name HandleOfficer


static func can_receive_archive(state: OfficerState) -> bool:
    return state.is_active


static func set_active(
        officer_states: Array, officer_records: Array,
        ref_RandomNumber: RandomNumber
        ) -> void:
    var id: int
    var has_active_officer: bool = false

    ArrayHelper.shuffle(officer_states, ref_RandomNumber)

    for i in officer_states:
        i.is_active = false
        if has_active_officer:
            continue

        id = i.get_instance_id()
        # `officer_records` is empty when the very first Document is delivered.
        # It should NOT be empty once again outside `if` statements. Push
        # another `id` into `officer_records` because this Officer has already
        # been selected twice: (1) Being hit by PC; (2) Being selected by
        # `set_active()`.
        if officer_records.is_empty():
            officer_records.push_back(id)
            _save_record(i, officer_records)
            has_active_officer = true
        # Add an element into `officer_records` right after it is cleared. DO
        # NOT let an empty `officer_records` go into the next loop.
        elif officer_records[-1] != id:
            officer_records.clear()
            _save_record(i, officer_records)
            has_active_officer = true
        else:
            if officer_records.size() + 1 > GameData.MAX_OFFICER_REPEAT:
                has_active_officer = false
            else:
                _save_record(i, officer_records)
                has_active_officer = true


static func _save_record(
        officer_state: OfficerState, officer_records: Array
        ) -> void:
    officer_state.is_active = true
    officer_records.push_back(officer_state.get_instance_id())

