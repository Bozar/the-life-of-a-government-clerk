class_name HandleClerkDesk


const DESK_ITEM_TAGS: Dictionary = {
    SubTag.ATLAS: SubTag.ATLAS_ON_DESK,
    SubTag.BOOK: SubTag.BOOK_ON_DESK,
    SubTag.CUP: SubTag.CUP_ON_DESK,
    SubTag.ENCYCLOPEDIA: SubTag.ENCYCLOPEDIA_ON_DESK,
}


static func send_document(state: ClerkState) -> bool:
    if state.has_document:
        # TODO: Keep part of overflowed progress.
        state.progress = 0
        return true
    return false


static func receive_raw_file(state: ClerkState, item_tag: StringName) -> bool:
    var desk_state: DeskState
    var desk_sprite: Sprite2D
    var new_tag: StringName
    var new_coord: Vector2i
    var new_tagged_sprite: TaggedSprite

    if state.has_document:
        return false
    elif not DESK_ITEM_TAGS.has(item_tag):
        return false

    desk_state = null
    new_tag = DESK_ITEM_TAGS[item_tag]
    for i in state.desk_states:
        desk_sprite = (i as DeskState).sprite
        if desk_sprite == null:
            # Put new file on the first (closest) empty desk.
            if desk_state == null:
                desk_state = i
        else:
            if desk_sprite.is_in_group(new_tag):
                return false

    if desk_state == null:
        return false

    new_coord = desk_state.coord
    new_tagged_sprite = SpriteFactory.create_trap(new_tag, new_coord, true)
    desk_state.sprite = new_tagged_sprite.sprite
    # TODO: Set remaining_page.
    desk_state.remaining_page = 1
    return true
