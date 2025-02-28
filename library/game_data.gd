class_name GameData


# Sidebar
const MIN_TURN_COUNTER: int = 1
const MAX_TURN_COUNTER: int = 9


# Sprite
const INTERNAL_FLOOR_Z_LAYER: int = ZLayer.GROUND + 1


# PC and Cart
const PC_SIGHT_RANGE: int = 5

const MIN_LOAD: int = 0
const MIN_LOAD_PER_TURN: int = 1
const MAX_LOAD_PER_TURN: int = 10
const MAX_LOAD_PER_CART: int = MAX_LOAD_PER_TURN * PAGE_CUP
const CLEAN_PHONE_CALL: int = int(MAX_LOAD_PER_CART * 1.5)

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


# Progress
const CHALLENGES_PER_DELIVERY: Array = [
    [],
    [GameProgress.TRASH_0,],
    [GameProgress.TRASH_0, GameProgress.PHONE_0,],
    [GameProgress.TRASH_0, GameProgress.PHONE_0, GameProgress.LEAK_0,],
    [GameProgress.TRASH_1, GameProgress.PHONE_0, GameProgress.LEAK_0,],
    [GameProgress.TRASH_1, GameProgress.PHONE_1, GameProgress.LEAK_0,],
    [GameProgress.TRASH_1, GameProgress.PHONE_1, GameProgress.LEAK_1,],
]
const TRASH_MOD_0: float = 0.6
const LEAK_REPEAT_0: int = 1
const LEAK_REPEAT_1: int = 2
const PHONE_REPEAT_0: int = 1
const PHONE_REPEAT_1: int = 3

const MAX_TRAP_DEFAULT: int = 0
const LEAK_REPEAT_DEFAULT: int = 0
const PHONE_REPEAT_DEFAULT: int = 0


# Reward
const INCOME_INITIAL: int = 2
const INCOME_DOCUMENT: int = 3

const MAX_MISSED_CALL: int = 3
const MISSED_CALL_PENALTY: int = 1


# Clerk and Officer
const PAYMENT_GARAGE: int = 1
const PAYMENT_CLEAN: int = 2

const MAX_CLERK_PROGRESS: int = PROGRESS_BOOK * (PAGE_BOOK * 3)
const OVERFLOW_PROGRESS: float = 0.25

const MAX_OFFICER_REPEAT: int = 1


# Servant
const BASE_SERVANT: int = 10
const ADD_SERVANT: int = 2
const MIN_DISTANCE_TO_PC: int = PC_SIGHT_RANGE

const BASE_DELAY: int = 1
const LOAD_AMOUNT_MULTIPLER: float = 1.0

const MIN_IDLE_DURATION: int = PAGE_BOOK
const MAX_IDLE_DURATION: int = MIN_IDLE_DURATION * 2
const SERVANT_ADD_COOLDOWN: int = BASE_PAGE

const MIN_REDUCE_PROGRESS: int = MIN_FILE_PROGRESS
const MAX_REDUCE_PROGRESS: int = MIN_FILE_PROGRESS * 3


# Raw file
const BASE_PAGE: int = 10
const PAGE_CUP: int = BASE_PAGE * 3
const PAGE_BOOK: int = PAGE_CUP * 2
const PAGE_ATLAS: int = PAGE_CUP * 4
const PAGE_ENCYCLOPEDIA: int = PAGE_CUP * 4

const MIN_FILE_PROGRESS: int = 125
const PROGRESS_BOOK: int = MIN_FILE_PROGRESS * 8
# One page: 3/2 Book | Overall effect: 3/4 BOOK
const PROGRESS_CUP: int = MIN_FILE_PROGRESS * 12
# One page: 3/8 Book | Overall effect: 3/4 BOOK
const PROGRESS_ATLAS: int = MIN_FILE_PROGRESS * 3
# One page: 7/8 Book | Overall effect: 7/4 BOOK
const PROGRESS_ENCYCLOPEDIA: int = MIN_FILE_PROGRESS * 7

const RAW_FILE_MIN_BASE_COOLDOWN: int = PAGE_CUP
const RAW_FILE_MAX_BASE_COOLDOWN: int = PAGE_BOOK
const RAW_FILE_ADD_COOLDOWN: int = BASE_PAGE * 2
const RAW_FILE_SEND_COUNTER: int = 1
