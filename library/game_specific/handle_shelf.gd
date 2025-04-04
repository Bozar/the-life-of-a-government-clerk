class_name HandleShelf


static func can_send_tmp_file(state: ShelfState) -> bool:
    return state.item_tag != ""


static func send_tmp_file(state: ShelfState) -> void:
    state.item_tag = ""


static func can_receive_tmp_file(state: ShelfState) -> bool:
    return state.item_tag == ""


static func receive_tmp_file(state: ShelfState, item_tag: StringName) -> void:
    state.item_tag = item_tag

