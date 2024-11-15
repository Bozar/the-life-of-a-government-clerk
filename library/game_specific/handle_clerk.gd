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
    if DESK_ITEM_PAGES.has(new_tag):
        desk_state.sub_tag = new_tag
        desk_state.max_page = DESK_ITEM_PAGES[new_tag]
        desk_state.remaining_page = DESK_ITEM_PAGES[new_tag]
    else:
        push_error("Page not found: %s" % new_tag)
    return true


static func update_progress(state: ClerkState) -> void:
    var desk_state: DeskState
    var remove_sprite: Sprite2D

    if state.has_empty_desk:
        return

    for i in state.desk_states:
        desk_state = i

        # Clean desk before updating progress. Otherwise Clerk sprite may not
        # be switched when progress is full.
        desk_state.remaining_page -= 1
        if desk_state.remaining_page < 1:
            remove_sprite = desk_state.sprite
            desk_state.sprite = null
            SpriteFactory.remove_sprite(remove_sprite)

        state.progress += DESK_ITEM_PROGRESS[desk_state.sub_tag]


static func reduce_progress(
        states: Array, ref_RandomNumber: RandomNumber
        ) -> void:
    var state: ClerkState
    var dup_states: Array

    dup_states = states.duplicate()
    ArrayHelper.shuffle(dup_states, ref_RandomNumber)
    dup_states.sort_custom(_sort_progress)

    for i in dup_states:
        state = i
        if not _is_valid_progress(state.progress):
            continue
        state.progress -= ref_RandomNumber.get_int(GameData.MIN_REDUCE_PROGRESS,
                GameData.MAX_REDUCE_PROGRESS + 1)
        break


static func switch_examine_mode(is_examine: bool, states: Array) -> void:
    var clerk_state: ClerkState
    var desk_state: DeskState

    for i in states:
        clerk_state = i
        _switch_clerk_sprite(is_examine, clerk_state)
        for j in clerk_state.desk_states:
            desk_state = j
            if desk_state.sprite == null:
                continue
            _switch_desk_sprite(is_examine, desk_state)


static func _switch_clerk_sprite(is_examine: bool, state: ClerkState) -> void:
    var visual_tag: StringName

    if is_examine:
        visual_tag = VisualTag.get_percent_tag(state.progress,
                GameData.MAX_CLERK_PROGRESS)
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
        visual_tag = VisualTag.get_percent_tag(state.remaining_page,
                state.max_page)
        VisualEffect.switch_sprite(state.sprite, visual_tag)
    else:
        visual_tag = VisualTag.DEFAULT
        VisualEffect.switch_sprite(state.sprite, visual_tag)


static func _is_valid_progress(progress: int) -> bool:
    return (progress > GameData.PROGRESS_CUP) \
            and (progress < GameData.MAX_CLERK_PROGRESS )


static func _sort_progress(left: ClerkState, right: ClerkState) -> bool:
    return left.progress < right.progress
