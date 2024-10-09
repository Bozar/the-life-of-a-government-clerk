class_name HandleRawFile


# TODO: Change cooldown in a more complicated way.
static func send_raw_file(raw_file_state: RawFileState) -> void:
    raw_file_state.cooldown = 1
