class_name HandleRawFile


static func send_raw_file(state: RawFileState, ref_RandomNumber: RandomNumber) \
        -> void:
    var base_cooldown: int = ref_RandomNumber.get_int(
            GameData.RAW_FILE_MIN_BASE_COOLDOWN,
            GameData.RAW_FILE_MAX_BASE_COOLDOWN + 1)
    var add_cooldown: int = state.send_counter * GameData.RAW_FILE_ADD_COOLDOWN

    # Cooldown is set in PC's turn and is decreased by 1 at the start of an
    # NPC's turn.
    state.cooldown = 1 + base_cooldown + add_cooldown
    state.send_counter += 1
    # print("CD: %s, Counter: %s" % [state.cooldown, state.send_counter])


static func reset_cooldown(states: Array) -> void:
    var state: RawFileState

    for i in states:
        state = i
        state.cooldown = 0
        state.send_counter -= GameData.RAW_FILE_SEND_COUNTER


static func update_cooldown(state: RawFileState) -> void:
    state.cooldown -= 1


static func reduce_cooldown(states: Array, ref_RandomNumber: RandomNumber) \
        -> void:

    var dup_states: Array
    var state: RawFileState

    dup_states = states.duplicate()
    ArrayHelper.shuffle(dup_states, ref_RandomNumber)

    for i in dup_states:
        state = i
        if state.cooldown > 0:
            state.cooldown -= GameData.RAW_FILE_ADD_COOLDOWN
            break