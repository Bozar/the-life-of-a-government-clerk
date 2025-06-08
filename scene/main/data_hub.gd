class_name DataHub
extends Node2D
## 1. Store public variables that will be used by other nodes.
## 2. If a property has an explicit setter function, it means the property is
## defined in a specific node and its value is read-only to other nodes.


var cash: int = GameData.INCOME_INITIAL
var account: int = 0
var delivery: int = GameData.MAX_LEVEL
var delay: int = 0

var ground_index: int = 0
var phone_index: int = 0
var max_trap: int
var max_call: int
var remaining_call: int = GameData.INITIAL_REMAINING_CALL

var show_all_sprite: bool = false


var pc: Sprite2D:
	get:
		return _pc


var pc_coord: Vector2i:
	get:
		return ConvertCoord.get_coord(pc)


var dummy_pc: Sprite2D:
	get:
		return _dummy_pc


var dummy_pc_coord: Vector2i:
	get:
		return ConvertCoord.get_coord(dummy_pc)


var game_mode: int:
	get:
		return _game_mode


var sidebar_message: String = "":
	get:
		return _sidebar_message


var linked_cart_state: LinkedCartState:
	get:
		return _linked_cart_state


var incoming_call: int:
	get:
		return _incoming_call


var raw_file_states: Array[RawFileState]:
	get:
		return _raw_file_states


var raw_file_sprites: Array[Sprite2D]:
	get:
		return _raw_file_sprites


var officer_states: Array[OfficerState]:
	get:
		return _officer_states


var clerk_states: Array[ClerkState]:
	get:
		return _clerk_states


var shelf_states: Array[ShelfState]:
	get:
		return _shelf_states


var officer_records: Array[int]:
	get:
		return _officer_records


var service_sprites: Array[Sprite2D]:
	get:
		return _service_sprites


var phone_booth_sprites: Array[Sprite2D]:
	get:
		return _phone_booth_sprites


var door_sprites: Array[Sprite2D]:
	get:
		return _door_sprites


var ground_coords: Array[Vector2i]:
	get:
		return _ground_coords


var phone_coords: Array[Vector2i]:
	get:
		return _phone_coords


var count_servant: int:
	get:
		return _count_servant


var count_empty_cart: int:
	get:
		return _count_empty_cart


var count_trash: int:
	get:
		return _count_trash


var count_idler: int:
	get:
		var states: Array = get_actor_states(SubTag.SERVANT)
		var servants: int = HandleServant.count_idle_servant(states)
		return servants


var turn_counter: int = GameData.MIN_TURN_COUNTER:
	set(value):
		if value > GameData.MAX_TURN_COUNTER:
			turn_counter = GameData.MIN_TURN_COUNTER
		else:
			turn_counter = max(value, GameData.MIN_TURN_COUNTER)


var challenge_level: int = 0:
	set(value):
		challenge_level = max(0, min(value, GameData.MAX_LEVEL))


var is_first_unload: bool:
	get:
		return _is_first_unload


var _pc: Sprite2D
var _dummy_pc: Sprite2D
var _game_mode: int = GameData.NORMAL_MODE
var _linked_cart_state := LinkedCartState.new()
var _incoming_call: int = 0
var _sidebar_message: String

var _x_to_indicator: Dictionary
var _y_to_indicator: Dictionary

var _actor_states: Dictionary = {}
var _raw_file_states: Array[RawFileState]
var _raw_file_sprites: Array[Sprite2D]
var _officer_states: Array[OfficerState]
var _clerk_states: Array[ClerkState]
var _shelf_states: Array[ShelfState]
var _officer_records: Array[int]
var _service_sprites: Array[Sprite2D]

var _challenge_states: Dictionary = {
	ChallengeTag.SHORT_CART: ChallengeTag.AVAILABLE,
	ChallengeTag.LONG_CART: ChallengeTag.AVAILABLE,
	ChallengeTag.SHELF: ChallengeTag.AVAILABLE,
	ChallengeTag.FIELD_REPORT: ChallengeTag.AVAILABLE,
	ChallengeTag.BOOK: ChallengeTag.AVAILABLE,
}

var _phone_booth_sprites: Array[Sprite2D]
var _door_sprites: Array[Sprite2D]
var _ground_coords: Array[Vector2i]
var _phone_coords: Array[Vector2i]

var _count_servant: int = 0
var _count_empty_cart: int = 0
var _count_trash: int = 0

var _is_first_unload: bool = true


func set_game_mode(value: int) -> void:
	_game_mode = value


func set_sidebar_message(value: String) -> void:
	_sidebar_message = value


func set_raw_file_states(value: RawFileState) -> void:
	_raw_file_states.push_back(value)


func set_officer_states(value: OfficerState) -> void:
	_officer_states.push_back(value)


func set_clerk_states(value: ClerkState) -> void:
	_clerk_states.push_back(value)


func set_shelf_states(value: ShelfState) -> void:
	_shelf_states.push_back(value)


func set_ground_coords(value: Vector2i) -> void:
	_ground_coords.push_back(value)


func set_phone_coords(value: Vector2i) -> void:
	_phone_coords.push_back(value)


func get_actor_state(sprite: Sprite2D) -> ActorState:
	if not sprite.is_in_group(MainTag.ACTOR):
		return null
	elif sprite.is_in_group(SubTag.PC):
		return null

	var id: int = sprite.get_instance_id()

	if _actor_states.has(id):
		return _actor_states[id]
	push_error("Actor not found: %s." % [sprite.name])
	return null


func get_actor_states(sub_tag: StringName) -> Array:
	var state: ActorState
	var states: Array

	for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(sub_tag):
		state = get_actor_state(i)
		if state != null:
			states.push_back(state)
	return states


func set_actor_state(sprite: Sprite2D, new_state: ActorState) -> void:
	_actor_states[sprite.get_instance_id()] = new_state


func remove_actor_state(sprite: Sprite2D) -> bool:
	return _actor_states.erase(sprite.get_instance_id())


func get_x_indicators(x: int) -> Array:
	return _x_to_indicator.get(x, [])


func set_x_indicators(x: int, sprite: Sprite2D) -> void:
	if _x_to_indicator.has(x):
		_x_to_indicator[x].push_back(sprite)
	else:
		_x_to_indicator[x] = [sprite]


func get_y_indicators(y: int) -> Array:
	return _y_to_indicator.get(y, [])


func set_y_indicators(y: int, sprite: Sprite2D) -> void:
	if _y_to_indicator.has(y):
		_y_to_indicator[y].push_back(sprite)
	else:
		_y_to_indicator[y] = [sprite]


func get_challenge_state(challenge_tag: int) -> int:
	if _challenge_states.has(challenge_tag):
		return _challenge_states[challenge_tag]
	push_error("Invalid challenge tag: %d" % challenge_tag)
	return ChallengeTag.INVALID


func set_challenge_state(challenge_tag: int, challenge_state: int) -> void:
	if not _challenge_states.has(challenge_tag):
		push_error("Invalid challenge tag: %d" % challenge_tag)
		return
	_challenge_states[challenge_tag] = challenge_state


func set_is_first_unload(value: bool) -> void:
	_is_first_unload = value


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
	for i: TaggedSprite in tagged_sprites:
		_init_sprite_data(i.sub_tag, i.sprite)


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
	for i: Sprite2D in sprites:
		if i.is_in_group(SubTag.SERVANT):
			_count_servant -= 1
		elif i.is_in_group(SubTag.EMPTY_CART):
			_count_empty_cart -= 1
		elif i.is_in_group(SubTag.TRASH):
			_count_trash -= 1
		elif i.is_in_group(SubTag.PHONE):
			_incoming_call -= 1
		elif i.is_in_group(SubTag.DUMMY_PC):
			_dummy_pc = null


func _init_sprite_data(sub_tag: StringName, sprite: Sprite2D) -> void:
	match sub_tag:
		SubTag.PHONE_BOOTH:
			_phone_booth_sprites.push_back(sprite)

		SubTag.DOOR:
			_door_sprites.push_back(sprite)

		SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA, \
				SubTag.FIELD_REPORT:
			_raw_file_sprites.push_back(sprite)

		SubTag.SALARY, SubTag.GARAGE, SubTag.STATION:
			_service_sprites.push_back(sprite)

		SubTag.SERVANT:
			_count_servant += 1

		SubTag.EMPTY_CART:
			_count_empty_cart += 1

		SubTag.TRASH:
			_count_trash += 1

		SubTag.PHONE:
			_incoming_call += 1

		SubTag.PC:
			_init_pc(sprite)

		SubTag.DUMMY_PC:
			_dummy_pc = sprite


func _init_pc(pc_sprite: Sprite2D) -> void:
	if pc != null:
		return

	_pc = pc_sprite
	Cart.init_linked_carts(pc, linked_cart_state)
	Cart.add_cart(GameData.MIN_CART, linked_cart_state)

