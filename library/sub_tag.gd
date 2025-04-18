class_name SubTag


# Ground
const DUNGEON_FLOOR: StringName = &"dungeon_floor"
const INTERNAL_FLOOR: StringName = &"internal_floor"


# Building
const WALL: StringName = &"wall"
const PHONE_BOOTH: StringName = &"phone_booth"
const DOOR: StringName = &"door"
const DESK: StringName = &"desk"


# Trap
const ATLAS_ON_DESK: StringName = &"atlas_on_desk"
const BOOK_ON_DESK: StringName = &"book_on_desk"
const CUP_ON_DESK: StringName = &"cup_on_desk"
const ENCYCLOPEDIA_ON_DESK: StringName = &"encyclopedia_on_desk"

const TRASH: StringName = &"trash"
const PROGRESS_BAR: StringName = &"progress_bar"


# Actor
const PC: StringName = &"pc"
const CLERK: StringName = &"clerk"
const OFFICER: StringName = &"officer"

const ATLAS: StringName = &"atlas"
const BOOK: StringName = &"book"
const CUP: StringName = &"cup"
const DOCUMENT: StringName = &"document"
const ENCYCLOPEDIA: StringName = &"encyclopedia"
const FIELD_REPORT: StringName = &"field_report"

const CART: StringName = &"cart"
const FULL: StringName = &"full"
const DETACHED: StringName = &"detached"

const SALARY: StringName = &"salary"
const GARAGE: StringName = &"garage"
const STATION: StringName = &"station"
const PHONE: StringName = &"phone"
const SHELF: StringName = &"shelf"

const SERVANT: StringName = &"servant"
const EMPTY_CART: StringName = &"empty_cart"


# Indicator
const INDICATOR_TOP: StringName = &"indicator_top"
const INDICATOR_BOTTOM: StringName = &"indicator_bottom"
const INDICATOR_LEFT: StringName = &"indicator_left"


# Visual effect
const HIGHLIGHT: StringName = &"highlight"


# Some sprites belong to more than one sub tag.
const RELATED_TAGS: Dictionary[StringName, Array] = {
    CLERK: [HIGHLIGHT],
    OFFICER: [HIGHLIGHT],
    
    ATLAS: [HIGHLIGHT],
    BOOK: [HIGHLIGHT],
    CUP: [HIGHLIGHT],
    ENCYCLOPEDIA: [HIGHLIGHT],
    FIELD_REPORT: [HIGHLIGHT],
    
    SALARY: [HIGHLIGHT],
    GARAGE: [HIGHLIGHT],
    STATION: [HIGHLIGHT],
    PHONE: [HIGHLIGHT],
    SHELF: [HIGHLIGHT],

    PHONE_BOOTH: [HIGHLIGHT],
    EMPTY_CART: [HIGHLIGHT],
}

