class_name InputTag


### Game Play ###

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const MOVE_UP: StringName = &"move_up"
const MOVE_DOWN: StringName = &"move_down"

const FAST_MOVE_LEFT: StringName = &"fast_move_left"
const FAST_MOVE_RIGHT: StringName = &"fast_move_right"
const FAST_MOVE_UP: StringName = &"fast_move_up"
const FAST_MOVE_DOWN: StringName = &"fast_move_down"

const SWITCH_EXAMINE: StringName = &"switch_examine"
const EXAMINE_NEXT_CART: StringName = &"examine_next_cart"
const SWITCH_HELP: StringName = &"switch_help"
const EXIT_ALT_MODE: StringName = &"exit_alt_mode"

const WIZARD_1: StringName = &"wizard_1"
const WIZARD_2: StringName = &"wizard_2"
const WIZARD_3: StringName = &"wizard_3"
const WIZARD_4: StringName = &"wizard_4"
const WIZARD_5: StringName = &"wizard_5"
const WIZARD_6: StringName = &"wizard_6"
const WIZARD_7: StringName = &"wizard_7"
const WIZARD_8: StringName = &"wizard_8"
const WIZARD_9: StringName = &"wizard_9"
const WIZARD_0: StringName = &"wizard_0"


### Game Over ###

const START_NEW_GAME: StringName = &"start_new_game"
const RESTART_GAME: StringName = &"restart_game"
const REPLAY_GAME: StringName = &"replay_game"
const QUIT_GAME: StringName = &"quit_game"
const COPY_SEED: StringName = &"copy_seed"
const COPY_SETTING: StringName = &"copy_setting"


### Menu ###

const OPEN_HELP_MENU: StringName = &"open_help_menu"
const OPEN_DEBUG_MENU: StringName = &"open_debug_menu"
const CLOSE_MENU: StringName = &"close_menu"

const NEXT_SCREEN: StringName = &"next_screen"
const PREVIOUS_SCREEN: StringName = &"previous_screen"

const PAGE_DOWN: StringName = &"page_down"
const PAGE_UP: StringName = &"page_up"
const LINE_DOWN: StringName = &"line_down"
const LINE_UP: StringName = &"line_up"
const PAGE_TOP: StringName = &"page_top"
const PAGE_BOTTOM: StringName = &"page_bottom"


### List of Inputs ###

const GAME_PLAY_INPUTS: Array[StringName] = [
	FAST_MOVE_LEFT,
	FAST_MOVE_RIGHT,
	FAST_MOVE_UP,
	FAST_MOVE_DOWN,

	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,

	SWITCH_EXAMINE,
	SWITCH_HELP,
	EXAMINE_NEXT_CART,
	EXIT_ALT_MODE,
]

const WIZARD_INPUTS: Array[StringName] = [
	WIZARD_1,
	WIZARD_2,
	WIZARD_3,
	WIZARD_4,
	WIZARD_5,
	WIZARD_6,
	WIZARD_7,
	WIZARD_8,
	WIZARD_9,
	WIZARD_0,
]

const UI_INPUTS: Array[StringName] = [
	NEXT_SCREEN,
	PREVIOUS_SCREEN,
	PAGE_DOWN,
	PAGE_UP,
	LINE_DOWN,
	LINE_UP,
	# PAGE_BOTTOM (Shift + G) goes before PAGE_TOP (G).
	PAGE_BOTTOM,
	PAGE_TOP,
]

