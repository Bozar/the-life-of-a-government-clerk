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
var max_phone: int


var pc: Sprite2D:
    get:
        return _pc


var pc_coord: Vector2i:
    get:
        return ConvertCoord.get_coord(pc)


var game_mode: int:
    get:
        return _game_mode


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
        var servants: int = HandleServant.count_idle_servant(
                NodeHub.ref_ActorAction.get_actor_states(SubTag.SERVANT)
                )
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


func get_count_trash_x(x: int) -> int:
    return _count_trash_x.get(x, 0)


func get_count_trash_y(y: int) -> int:
    return _count_trash_y.get(y, 0)


var _pc: Sprite2D
var _game_mode: int = PcAction.NORMAL_MODE
var _linked_cart_state := LinkedCartState.new()
var _incoming_call: int = 0

var _raw_file_states: Array[RawFileState]
var _raw_file_sprites: Array[Sprite2D]
var _officer_states: Array[OfficerState]
var _clerk_states: Array[ClerkState]
var _shelf_states: Array[ShelfState]
var _officer_records: Array[int]
var _service_sprites: Array[Sprite2D]

var _phone_booth_sprites: Array[Sprite2D]
var _ground_coords: Array[Vector2i]
var _phone_coords: Array[Vector2i]

var _count_servant: int = 0
var _count_empty_cart: int = 0

var _count_trash: int = 0
var _count_trash_x: Dictionary[int, int]
var _count_trash_y: Dictionary[int, int]


func set_pc(value: Sprite2D) -> void:
    _pc = value


func set_game_mode(value: int) -> void:
    _game_mode = value


func add_incoming_call(value: int) -> void:
    _incoming_call += value


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


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
    for i: TaggedSprite in tagged_sprites:
        match i.sub_tag:
            SubTag.PHONE_BOOTH:
                _phone_booth_sprites.push_back(i.sprite)
            SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA, \
                    SubTag.FIELD_REPORT:
                _raw_file_sprites.push_back(i.sprite)
            SubTag.SALARY, SubTag.GARAGE, SubTag.STATION:
                _service_sprites.push_back(i.sprite)
            SubTag.SERVANT:
                _count_servant += 1
            SubTag.TRASH:
                _update_count_trash(i.sprite, 1)
            SubTag.EMPTY_CART:
                _count_empty_cart += 1


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
    for i: Sprite2D in sprites:
        if i.is_in_group(SubTag.SERVANT):
            _count_servant -= 1
        elif i.is_in_group(SubTag.TRASH):
            _update_count_trash(i, -1)
        elif i.is_in_group(SubTag.EMPTY_CART):
            _count_empty_cart -= 1


func _update_count_trash(sprite: Sprite2D, value: int) -> void:
    var coord: Vector2i = ConvertCoord.get_coord(sprite)

    _count_trash += value

    if _count_trash_x.has(coord.x):
        _count_trash_x[coord.x] += value
        if _count_trash_x[coord.x] == 0:
            _count_trash_x.erase(coord.x)
    else:
        _count_trash_x[coord.x] = value

    if _count_trash_y.has(coord.y):
        _count_trash_y[coord.y] += value
        if _count_trash_y[coord.y] == 0:
            _count_trash_y.erase(coord.y)
    else:
        _count_trash_y[coord.y] = value

