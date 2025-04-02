class_name HandleRawFile


static func can_send_file(state: RawFileState) -> bool:
    return state.cooldown < 1


static func send_raw_file(
        state: RawFileState, ref_RandomNumber: RandomNumber,
        servant_cooldown: int
        ) -> void:
    var base_cooldown: int = ref_RandomNumber.get_int(
            GameData.RAW_FILE_MIN_BASE_COOLDOWN,
            GameData.RAW_FILE_MAX_BASE_COOLDOWN + 1)
    var send_cooldown: int = state.send_counter * GameData.RAW_FILE_ADD_COOLDOWN

    # Cooldown is set in PC's turn and is decreased by 1 at the start of an
    # NPC's turn.
    state.max_cooldown = base_cooldown + send_cooldown + servant_cooldown
    state.cooldown = 1 + state.max_cooldown
    state.send_counter += 1
    # print("CD: %s, Counter: %s" % [state.cooldown, state.send_counter])


static func reset_cooldown(raw_file_states: Array) -> void:
    for i: RawFileState in raw_file_states:
        i.cooldown = 0
        i.send_counter -= GameData.RAW_FILE_SEND_COUNTER


static func update_cooldown(state: RawFileState) -> void:
    state.cooldown -= GameData.RAW_FILE_REDUCE_COOLDOWN_PASSIVE


static func reduce_cooldown(
        raw_file_states: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    var dup_states: Array = raw_file_states.duplicate()

    ArrayHelper.shuffle(dup_states, ref_RandomNumber)
    dup_states.sort_custom(_sort_cooldown)

    for i: RawFileState in dup_states:
        if i.cooldown > 0:
            i.cooldown -= GameData.RAW_FILE_REDUCE_COOLDOWN_PUSH_SERVANT
            break


static func can_receive_servant(state: RawFileState) -> bool:
    return state.cooldown > 0


static func receive_servant(state: RawFileState) -> void:
    state.cooldown -= GameData.RAW_FILE_REDUCE_COOLDOWN_UNLOAD_SERVANT


static func switch_examine_mode(is_enter: bool, states: Array) -> void:
    var progress_bar: Sprite2D
    var remaining_cooldown: int
    var visual_tag: StringName = VisualTag.DEFAULT

    for i: RawFileState in states:
        progress_bar = SpriteState.get_trap_by_coord(i.progress_bar_coord)
        if progress_bar == null:
            continue

        if is_enter:
            remaining_cooldown = i.max_cooldown - i.cooldown
            visual_tag = VisualTag.get_percent_tag(
                    remaining_cooldown, i.max_cooldown
                    )
        VisualEffect.switch_sprite(progress_bar, visual_tag)


static func _sort_cooldown(left: RawFileState, right: RawFileState) -> bool:
    return left.cooldown < right.cooldown

