class_name GameData


const PC_SIGHT_RANGE: int = 5

const MIN_LOAD_FACTOR: int = 0
const MAX_LOAD_FACTOR: int = 100

const MIN_CART: int = 3
const ADD_CART: int = 3

const CART_LENGTH_SHORT: int = 4
const CART_LENGTH_LONG: int = 7

const MIN_TURN_COUNTER: int = 1
const MAX_TURN_COUNTER: int = 99

const MAX_DELIVERY: int = 10
const MAX_SERVICE: int = 2
const MAX_OFFICER_REPEAT: int = 1

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

const MIN_FILE_PROGRESS: int = 125
const PROGRESS_BOOK: int = MIN_FILE_PROGRESS * 8
# One page: 3/2 Book | Overall effect: 3/4 BOOK
const PROGRESS_CUP: int = MIN_FILE_PROGRESS * 12
# One page: 3/8 Book | Overall effect: 3/4 BOOK
const PROGRESS_ATLAS: int = MIN_FILE_PROGRESS * 3
# One page: 7/8 Book | Overall effect: 7/4 BOOK
const PROGRESS_ENCYCLOPEDIA: int = MIN_FILE_PROGRESS * 7

const MAX_CLERK_PROGRESS: int = PROGRESS_BOOK * (PAGE_BOOK * 3)
const OVERFLOW_PROGRESS: float = 0.25

const BASE_SERVANT: int = 10
const ADD_SERVANT: int = 2
const MIN_IDLE_DURATION: int = 60
const MAX_IDLE_DURATION: int = MIN_IDLE_DURATION * 2

const RAW_FILE_MIN_BASE_COOLDOWN: int = 20
const RAW_FILE_MAX_BASE_COOLDOWN: int = 25
const RAW_FILE_ADD_COOLDOWN: int = 5
const RAW_FILE_SEND_COUNTER: int = 1
