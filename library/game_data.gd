class_name GameData


### Game Mode ###

enum {
	NORMAL_MODE,
	EXAMINE_MODE,
}


### Sidebar ###

const MIN_TURN_COUNTER: int = 1
const MAX_TURN_COUNTER: int = 99

enum WARN {
	NO_ALERT,
	ADD_CART,
	CLEAN,
	DOCUMENT,
	LOAD,
	PUSH,
	REPORT,
	SHELF,
	SLOW,
	TRAPPED,
}

const WARN_TO_STRING: Dictionary = {
	WARN.NO_ALERT: "",
	WARN.TRAPPED: "TRAPPED",
	WARN.SLOW: "SLOW",
	WARN.PUSH: "PUSH",
	WARN.CLEAN: "CLEAN",
	WARN.SHELF: "SHELF",
	WARN.LOAD: "LOAD",
	WARN.DOCUMENT: "DOCUMENT",
	WARN.REPORT: "REPORT",
	WARN.ADD_CART: "ADD_CART",
}


### Sprite ###

const INTERNAL_FLOOR_Z_LAYER: int = ZLayer.GROUND + 1


### PC and Cart ###

const PC_SIGHT_RANGE: int = 5

const MIN_LOAD: int = 0
const MIN_LOAD_PER_TURN: int = 1
const MAX_LOAD_PER_TURN: int = 10
const MAX_LOAD_PER_CART: int = MAX_LOAD_PER_TURN * PAGE_CUP

# 0.3 * PAGE_CUP (30) = 9 => Answering a Phone call grants 9 turns' survival
# time. A Phone is 5 (PC_SIGHT_RANGE) to 10 grids (PC_SIGHT_RANGE * 2) away from
# PC.
const CLEAN_PHONE_CALL: int = int(MAX_LOAD_PER_CART * 0.3)
# The first Cart loads Trash more slowly when pushing a Servant.
const CLEAN_SERVANT: int = 3

const SAFE_LOAD_AMOUNT_PERCENT_1: float = 0.4
const SAFE_LOAD_AMOUNT_PERCENT_2: float = 0.6
const SAFE_LOAD_AMOUNT_PERCENT_3: float = 0.8

const ADD_LOADS: Array = [
	[4, 3, 2, 1, 1,],
	[4, 2, 2, 2, 1,],
	[3, 3, 2, 2, 1,],
	[3, 3, 3, 1, 1,],
	[3, 2, 2, 2, 2,],
]

const MIN_CART: int = 3
const ADD_CART: int = 3

const CART_LENGTH_SHORT: int = 3
const CART_LENGTH_LONG: int = 6

const ADD_EMPTY_CART_LENGTH: int = 1
const ADD_EMPTY_CART_CHANCE: int = 30
const MIN_EMPTY_CART_DURATION: int = MAX_DISTANCE_TO_PC * 2
const MAX_EMPTY_CART_DURATION: int = MAX_DISTANCE_TO_PC * 4


### Progress & Challenge ###

const MAX_LEVEL: int = 4
const MIN_LEAK_LEVEL: int = 1

const MAX_PHONE: int = 3
const MIN_PHONE: int = 0
const DEFAULT_PHONE: int = 2

const NEW_ACTOR_INTERVAL: int = 7
const NEW_TRAP_INTERVAL: int = 5

const LEVEL_TO_TRAP: Dictionary = {
	0: 2,
	1: 3,
	2: 4,
	3: 5,
	4: 5,
}


### Reward ###

const INCOME_INITIAL: int = 2
const INCOME_DOCUMENT: int = 3

const MAX_MISSED_CALL: int = 1
const MISSED_CALL_PENALTY: int = 1


### Clerk and Officer ###

const PAYMENT_GARAGE: int = 1
const PAYMENT_CLEAN: int = 2
const MIN_PAYMENT: int = 0

# 180 000 = ((125 * 8) * (10 * 3 * 2)) * 3
# Ideally, a Clerk needs 3 Books, (60 + 60) turns to create a Document. Note
# that the Clerk can read two Raw Files and increase progress simultaneously.
const MAX_CLERK_PROGRESS: int = (PROGRESS_BOOK * PAGE_BOOK) * 3
const OVERFLOW_PROGRESS: float = 0.4

const PROGRESS_LEAK_1: int = MIN_FILE_PROGRESS
const PROGRESS_LEAK_2: int = MIN_FILE_PROGRESS * 3
const MIN_LEAK_IDLER: int = 1

const MAX_OFFICER_REPEAT: int = 2


### Servant ###

const BASE_SERVANT: int = 6
const SHELF_TO_SERVANT: int = 3
const MIN_DISTANCE_TO_PC: int = PC_SIGHT_RANGE
const MAX_DISTANCE_TO_PC: int = PC_SIGHT_RANGE * 2

const MIN_IDLE_DURATION: int = PAGE_ATLAS
const MAX_IDLE_DURATION: int = MIN_IDLE_DURATION * 3


### Trash ###

const BASE_DELAY: int = 5
const LOAD_FACTOR_SHORT: float = 1.0
const LOAD_FACTOR_LONG: float = 3.0
const MAX_TRASH_PER_LINE: int = 3
const MAX_SERVANT_PER_LINE: int = 1

const ADD_TRASH_INTERVAL: int = 3


### Raw file ###

# A Clerk takes X turns to finish reading a Raw File.
const BASE_PAGE: int = 10
const PAGE_CUP: int = BASE_PAGE * 3
const PAGE_BOOK: int = PAGE_CUP * 2
const PAGE_ATLAS: int = PAGE_CUP * 4
const PAGE_ENCYCLOPEDIA: int = PAGE_CUP * 4

# `MIN_FILE_PROGRESS` can be any number. However, it would be nice if every Raw
# File's overall effect is an integer.
const MIN_FILE_PROGRESS: int = 125
const PROGRESS_BOOK: int = MIN_FILE_PROGRESS * 8
# One page: 3/2 Book | Overall effect: 3/4 BOOK
const PROGRESS_CUP: int = MIN_FILE_PROGRESS * 12
# One page: 3/8 Book | Overall effect: 3/4 BOOK
const PROGRESS_ATLAS: int = MIN_FILE_PROGRESS * 3
# One page: 7/8 Book | Overall effect: 7/4 BOOK
const PROGRESS_ENCYCLOPEDIA: int = MIN_FILE_PROGRESS * 7

# Cooldown decreases very slowly per turn.
const RAW_FILE_REDUCE_COOLDOWN_PASSIVE: int = 1

const RAW_FILE_REDUCE_COOLDOWN_PUSH_SERVANT: int = RAW_FILE_ADD_COOLDOWN_SEND
const RAW_FILE_REDUCE_COOLDOWN_UNLOAD_SERVANT: int \
		= RAW_FILE_ADD_COOLDOWN_SEND * 5
const RAW_FILE_REDUCE_COOLDOWN_MIN_PERCENT: float = 0.1
const RAW_FILE_REDUCE_COOLDOWN_MAX_PERCENT: float = 0.9

# Base cooldown & active effects are multiplied by a factor.
const RAW_FILE_COOLDOWN_MOD: int = 20
const RAW_FILE_MIN_BASE_COOLDOWN: int = PAGE_CUP * RAW_FILE_COOLDOWN_MOD
const RAW_FILE_MAX_BASE_COOLDOWN: int = PAGE_ATLAS * RAW_FILE_COOLDOWN_MOD

const RAW_FILE_ADD_COOLDOWN_SEND: int = PAGE_BOOK * RAW_FILE_COOLDOWN_MOD
const RAW_FILE_ADD_COOLDOWN_SERVANT: int = PAGE_BOOK * RAW_FILE_COOLDOWN_MOD

const RAW_FILE_SEND_COUNTER: int = 1

