class_name GameData


### Sidebar ###

const MIN_TURN_COUNTER: int = 1
const MAX_TURN_COUNTER: int = 99


### Sprite ###

const INTERNAL_FLOOR_Z_LAYER: int = ZLayer.GROUND + 1


### PC and Cart ###

const PC_SIGHT_RANGE: int = 5

const MIN_LOAD: int = 0
const MIN_LOAD_PER_TURN: int = 1
const MAX_LOAD_PER_TURN: int = 10
const MAX_LOAD_PER_CART: int = MAX_LOAD_PER_TURN * PAGE_CUP
const CLEAN_PHONE_CALL: int = int(MAX_LOAD_PER_CART * 0.4)

const ADD_LOADS: Array = [
    [4, 3, 2, 1, 1,],
    [4, 2, 2, 2, 1,],
    [3, 3, 2, 2, 1,],
    [3, 3, 3, 1, 1,],
    [3, 2, 2, 2, 2,],
]

const MIN_CART: int = 3
const ADD_CART: int = 3

const CART_LENGTH_SHORT: int = 4
const CART_LENGTH_LONG: int = 7


### Progress ###

const MAX_LEVEL: int = 5
const MIN_LEVEL_LEAK: int = 2

const MAX_PHONE: int = 3
const MAX_TRAP: int = 25


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
const OVERFLOW_PROGRESS: float = 0.25

const MIN_PROGRESS_LEAK: int = MIN_FILE_PROGRESS
const MAX_PROGRESS_LEAK: int = MIN_FILE_PROGRESS * 3

const MAX_OFFICER_REPEAT: int = 2


### Servant ###

const BASE_SERVANT: int = 5
const SHELF_TO_SERVANT: int = 2
const MIN_DISTANCE_TO_PC: int = PC_SIGHT_RANGE
const MAX_DISTANCE_TO_PC: int = PC_SIGHT_RANGE * 2

# Ideally, it takes 4 turns to bypass a Trash.
const BASE_DELAY: int = 3
const LOAD_AMOUNT_MULTIPLER: float = 2.0

const MIN_IDLE_DURATION: int = PAGE_BOOK
const MAX_IDLE_DURATION: int = MIN_IDLE_DURATION * 2


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
const RAW_FILE_REDUCE_COOLDOWN_UNLOAD_SERVANT: int = \
        RAW_FILE_ADD_COOLDOWN_SEND * 5

# Base cooldown & active effects are multiplied by a factor.
const RAW_FILE_COOLDOWN_MOD: int = 20
const RAW_FILE_MIN_BASE_COOLDOWN: int = PAGE_CUP * RAW_FILE_COOLDOWN_MOD
const RAW_FILE_MAX_BASE_COOLDOWN: int = PAGE_ATLAS * RAW_FILE_COOLDOWN_MOD

const RAW_FILE_ADD_COOLDOWN_SEND: int = PAGE_BOOK * RAW_FILE_COOLDOWN_MOD
const RAW_FILE_ADD_COOLDOWN_SERVANT: int = PAGE_CUP * RAW_FILE_COOLDOWN_MOD

const RAW_FILE_SEND_COUNTER: int = 1

