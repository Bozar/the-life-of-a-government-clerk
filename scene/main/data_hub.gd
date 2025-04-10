class_name DataHub
extends Node2D
## 1. Store public variables that will be used by other nodes.
## 2. If a property has an explicit setter function, it means the property is
## defined in a specific node and its value is read-only to other nodes.


var cash: int = GameData.INCOME_INITIAL
var account: int = 0
var delivery: int = GameData.MAX_LEVEL
var progress_state := ProgressState.new()
var delay: int = 0


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


var count_combined_idler: int:
    get:
        var servants: int = HandleServant.count_idle_servant(
                NodeHub.ref_ActorAction.get_actor_states(SubTag.SERVANT)
                )
        return servants \
                * (NodeHub.ref_DataHub.progress_state.challenge_level + 1)


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

