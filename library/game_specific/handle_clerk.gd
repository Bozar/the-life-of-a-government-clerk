class_name HandleClerk


const DESK_ITEM_TAGS: Dictionary = {
    SubTag.ATLAS: SubTag.ATLAS_ON_DESK,
    SubTag.BOOK: SubTag.BOOK_ON_DESK,
    SubTag.CUP: SubTag.CUP_ON_DESK,
    SubTag.ENCYCLOPEDIA: SubTag.ENCYCLOPEDIA_ON_DESK,
}

const DESK_ITEM_PAGES: Dictionary = {
    SubTag.ATLAS_ON_DESK: GameData.PAGE_ATLAS,
    SubTag.BOOK_ON_DESK: GameData.PAGE_BOOK,
    SubTag.CUP_ON_DESK: GameData.PAGE_CUP,
    SubTag.ENCYCLOPEDIA_ON_DESK: GameData.PAGE_ENCYCLOPEDIA,
}

const DESK_ITEM_PROGRESS: Dictionary = {
    SubTag.ATLAS_ON_DESK: GameData.PROGRESS_ATLAS,
    SubTag.BOOK_ON_DESK: GameData.PROGRESS_BOOK,
    SubTag.CUP_ON_DESK: GameData.PROGRESS_CUP,
    SubTag.ENCYCLOPEDIA_ON_DESK: GameData.PROGRESS_ENCYCLOPEDIA,
}


static func send_document(state: ClerkState) -> bool:
    var new_progress: int

    if state.has_document:
        new_progress = state.progress
        new_progress -= GameData.MAX_CLERK_PROGRESS
        new_progress = max(0, new_progress)
        new_progress = floor(GameData.OVERFLOW_PROGRESS * new_progress)
        state.progress = new_progress
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
    for i: DeskState in state.desk_states:
        desk_sprite = i.sprite
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
    if DESK_ITEM_PAGES.has(new_tag):
        desk_state.sub_tag = new_tag
        desk_state.max_page = DESK_ITEM_PAGES[new_tag]
        desk_state.remaining_page = DESK_ITEM_PAGES[new_tag]
    else:
        push_error("Page not found: %s" % new_tag)
    return true


static func update_progress(state: ClerkState) -> void:
    var remove_sprite: Sprite2D

    if state.has_empty_desk:
        return

    for i: DeskState in state.desk_states:
        # Clean desk before updating progress. Otherwise Clerk sprite may not
        # be switched when progress is full.
        i.remaining_page -= 1
        if i.remaining_page < 1:
            remove_sprite = i.sprite
            i.sprite = null
            SpriteFactory.remove_sprite(remove_sprite)

        state.progress += DESK_ITEM_PROGRESS[i.sub_tag]


static func reduce_progress(
        clerk_states: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    var dup_states: Array

    dup_states = clerk_states.duplicate()
    ArrayHelper.shuffle(dup_states, ref_RandomNumber)
    dup_states.sort_custom(_sort_progress)

    for i: ClerkState in dup_states:
        if not _is_valid_progress(i.progress):
            continue
        i.progress -= ref_RandomNumber.get_int(
                GameData.MIN_REDUCE_PROGRESS, GameData.MAX_REDUCE_PROGRESS + 1
                )
        break


static func switch_examine_mode(is_enter: bool, states: Array) -> void:
    for cs: ClerkState in states:
        _switch_clerk_sprite(is_enter, cs)
        for ds: DeskState in cs.desk_states:
            if ds.sprite == null:
                continue
            _switch_desk_sprite(is_enter, ds)


static func _switch_clerk_sprite(is_examine: bool, state: ClerkState) -> void:
    var visual_tag: StringName

    if is_examine:
        visual_tag = VisualTag.get_percent_tag(
                state.progress, GameData.MAX_CLERK_PROGRESS
                )
        VisualEffect.switch_sprite(state.sprite, visual_tag)
    else:
        if state.has_document:
            visual_tag = VisualTag.ACTIVE
        else:
            visual_tag = VisualTag.DEFAULT
        VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _switch_desk_sprite(is_examine: bool, state: DeskState) -> void:
    var visual_tag: StringName

    if is_examine:
        visual_tag = VisualTag.get_percent_tag(
                state.remaining_page, state.max_page
                )
        VisualEffect.switch_sprite(state.sprite, visual_tag)
    else:
        visual_tag = VisualTag.DEFAULT
        VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _is_valid_progress(progress: int) -> bool:
    return (progress > GameData.PROGRESS_CUP) \
            and (progress < GameData.MAX_CLERK_PROGRESS )


static func _sort_progress(left: ClerkState, right: ClerkState) -> bool:
    return left.progress < right.progress
