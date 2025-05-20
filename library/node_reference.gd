class_name NodeReference


const SPRITE_ROOT: String = "SpriteRoot"
const PC_ACTION: String = "PcAction"
const PLAYER_INPUT: String = "PlayerInput"
const SPRITE_COORD: String = "SpriteCoord"
const SPRITE_TAG: String = "SpriteTag"
const SCHEDULE: String = "Schedule"
const ACTOR_ACTION: String = "ActorAction"
const RANDOM_NUMBER: String = "RandomNumber"
const INIT_WORLD: String = "InitWorld"
const SIGNAL_HUB: String = "SignalHub"
const DATA_HUB: String = "DataHub"

const SIDEBAR: String = "Sidebar"

const HELP_SCREEN: String = "HelpScreen"
const DEBUG_SCREEN: String = "DebugScreen"

const SPRITE_FACTORY: String = "/root/SpriteFactory"
const SPRITE_STATE: String = "/root/SpriteState"


const SIGNAL_SPRITE_CREATED: String = "sprite_created"
const SIGNAL_SPRITE_REMOVED: String = "sprite_removed"

const SIGNAL_TURN_STARTED: String = "turn_started"
const SIGNAL_GAME_OVER: String = "game_over"

const SIGNAL_ACTION_PRESSED: String = "action_pressed"
const SIGNAL_UI_FORCE_UPDATED: String = "ui_force_updated"
const SIGNAL_UI_UPDATED: String = "ui_updated"


# {source_node: {signal_name: [target_node_1, ...]}, ...}
const SIGNAL_CONNECTIONS: Dictionary = {
	SIGNAL_HUB: {
		SIGNAL_GAME_OVER: [
			SCHEDULE, PC_ACTION, PLAYER_INPUT, SIDEBAR,
		],
		SIGNAL_SPRITE_CREATED: [
			SPRITE_ROOT, PC_ACTION, SPRITE_COORD, SPRITE_TAG,
			SCHEDULE, ACTOR_ACTION, DATA_HUB,
		],
		SIGNAL_SPRITE_REMOVED: [
			SPRITE_ROOT, SPRITE_COORD, SPRITE_TAG, SCHEDULE,
			ACTOR_ACTION, PC_ACTION, DATA_HUB,
		],
		SIGNAL_UI_FORCE_UPDATED: [
			SIDEBAR,
		],
		SIGNAL_UI_UPDATED: [
			SIDEBAR,
		],
		SIGNAL_ACTION_PRESSED: [
			PC_ACTION, RANDOM_NUMBER, SIDEBAR, SPRITE_ROOT,
			HELP_SCREEN, DEBUG_SCREEN,
		],
		SIGNAL_TURN_STARTED: [
			PLAYER_INPUT, PC_ACTION, ACTOR_ACTION,
		],
	},
}


const NODE_NAMES: Array = [
	SPRITE_COORD,
	SPRITE_TAG,
	SCHEDULE,
	PC_ACTION,
	ACTOR_ACTION,
	RANDOM_NUMBER,
	SIGNAL_HUB,
	DATA_HUB,
]

