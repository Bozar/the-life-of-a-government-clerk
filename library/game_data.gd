class_name GameData


const PC_SIGHT_RANGE: int = 5

const MIN_LOAD_FACTOR: int = 0
const MAX_LOAD_FACTOR: int = 100

const MIN_CART: int = 3
const ADD_CART: int = 3

const CART_LENGTH_SHORT: int = 4
const CART_LENGTH_LONG: int = 7

const MIN_TURN_COUNTER: int = 0
const MAX_TURN_COUNTER: int = 99999

const MAX_DELIVERY: int = 10
const MAX_SERVICE: int = 2

const BASE_DELAY: int = 1
const LOAD_FACTOR_MULTIPLER: float = 0.01

const PAYMENT_SERVICE: int = 1
const PAYMENT_CLEAN: int = 1

const INCOME_ORDER: int = 1
const INCOME_DOCUMENT: int = 3

const PAGE_CUP: int = 30
const PAGE_BOOK: int = PAGE_CUP * 2
const PAGE_ATLAS: int = PAGE_CUP * 4
const PAGE_ENCYCLOPEDIA: int = PAGE_CUP * 4

# 3/2 = 1.5 | 3/8 = 0.375 | 7/8 = 0.875
const PROGRESS_BOOK: int = 1000
# Overall effect: 3/4 BOOK
const PROGRESS_CUP: int = int(PROGRESS_BOOK * 1.5)
# Overall effect: 3/4 BOOK
const PROGRESS_ATLAS: int = int(PROGRESS_BOOK * 0.375)
# Overall effect: 7/4 BOOK
const PROGRESS_ENCYCLOPEDIA: int = int(PROGRESS_BOOK * 0.875)

const MAX_CLERK_PROGRESS: int = PROGRESS_BOOK * (PAGE_BOOK * 3)
const OVERFLOW_PROGRESS: float = 0.25

const BASE_SERVANT: int = 10
const ADD_SERVANT: int = 2

const RAW_FILE_MIN_BASE_COOLDOWN: int = 20
const RAW_FILE_MAX_BASE_COOLDOWN: int = 25
const RAW_FILE_ADD_COOLDOWN: int = 5
const RAW_FILE_SEND_COUNTER: int = 1
