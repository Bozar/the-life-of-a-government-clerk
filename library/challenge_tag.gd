class_name ChallengeTag


enum {
	INVALID,
	AVAILABLE,
	FINISHED,
	FAILED,
}


enum {
	SHORT_CART,
	LONG_CART,
	SHELF,
	FIELD_REPORT,
	BOOK,
}


const ALL_CHALLENGES: Array = [
	SHORT_CART,
	LONG_CART,
	SHELF,
	FIELD_REPORT,
	BOOK,
]


const STATE_TO_STRING: Dictionary = {
	AVAILABLE: " ",
	FINISHED: "+",
	FAILED: "-",
}


const NAME_TO_STRING: Dictionary = {
	SHORT_CART: "P",
	LONG_CART: "K",
	SHELF: "B",
	FIELD_REPORT: "C",
	BOOK: "R",
}

const NO_NAME: String = "?"

