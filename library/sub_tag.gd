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

const INDICATOR_0: StringName = &"indicator_0"
const INDICATOR_1: StringName = &"indicator_1"
const INDICATOR_2: StringName = &"indicator_2"
const INDICATOR_3: StringName = &"indicator_3"
const INDICATOR_4: StringName = &"indicator_4"
const INDICATOR_5: StringName = &"indicator_5"
const INDICATOR_6: StringName = &"indicator_6"
const INDICATOR_7: StringName = &"indicator_7"
const INDICATOR_8: StringName = &"indicator_8"
const INDICATOR_9: StringName = &"indicator_9"

const INDICATOR_A: StringName = &"indicator_a"
const INDICATOR_B: StringName = &"indicator_b"
const INDICATOR_C: StringName = &"indicator_c"
const INDICATOR_D: StringName = &"indicator_d"
const INDICATOR_E: StringName = &"indicator_e"
const INDICATOR_F: StringName = &"indicator_f"
const INDICATOR_G: StringName = &"indicator_g"
const INDICATOR_H: StringName = &"indicator_h"
const INDICATOR_J: StringName = &"indicator_j"
const INDICATOR_K: StringName = &"indicator_k"
const INDICATOR_L: StringName = &"indicator_l"


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

