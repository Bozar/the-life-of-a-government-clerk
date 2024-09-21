class_name ActorAction
extends Node2D


const RAW_FILE_TAGS: Array = [
    SubTag.ATLAS,
    SubTag.BOOK,
    SubTag.CUP,
    SubTag.ENCYCLOPEDIA,
]


var _ref_RandomNumber: RandomNumber
var _ref_PcAction: PcAction
var _ref_GameProgress: GameProgress


var _pc: Sprite2D
var _actor_states: Dictionary = {}
# var _map_2d: Dictionary = Map2D.init_map(DijkstraPathfinding.UNKNOWN)


func get_service_type(sprite: Sprite2D) -> int:
    var state: ServiceState = _get_actor_state(sprite)
    return state.service_type


func use_service(sprite: Sprite2D) -> void:
    var state: ServiceState = _get_actor_state(sprite)
    HandleService.use_service(state)


func receive_document() -> void:
    _set_service_type(true)
    _set_raw_file_cooldown()


func raw_file_is_available(sprite: Sprite2D) -> bool:
    var state: RawFileState = _get_actor_state(sprite)
    return state.cooldown < 1


func send_raw_file(sprite: Sprite2D) -> void:
    var state: RawFileState = _get_actor_state(sprite)
    HandleRawFile.send_raw_file(state)


# TODO: Call this function when:
#   Unload D: `reset_type` = true
#   Unload A/B/C/E and `service_counter` < 2: `reset_type` = false
func _set_service_type(reset_type: bool) -> void:
    var state: ServiceState

    for i in SpriteState.get_sprites_by_sub_tag(SubTag.SERVICE):
        state = _get_actor_state(i)
        HandleService.set_service_type(state, reset_type, _ref_RandomNumber)


func _set_raw_file_cooldown() -> void:
    var state: RawFileState

    for sub_tag in RAW_FILE_TAGS:
        for i in SpriteState.get_sprites_by_sub_tag(sub_tag):
            state = _get_actor_state(i)
            state.cooldown = 0


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    var actor_state: ActorState = _get_actor_state(sprite)

    if actor_state == null:
        return

    ScheduleHelper.start_next_turn()


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    var id: int

    for i: TaggedSprite in tagged_sprites:
        if not i.main_tag == MainTag.ACTOR:
            continue
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
        else:
            id = i.sprite.get_instance_id()
            match i.sub_tag:
                SubTag.SERVICE:
                    _actor_states[id] = ServiceState.new(i.sprite)
                SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
                    _actor_states[id] = RawFileState.new(i.sprite)
                _:
                    _actor_states[id] = ActorState.new(i.sprite)


func _on_SpriteFactory_sprite_removed(sprites: Array) -> void:
    var id: int

    for i: Sprite2D in sprites:
        if not _is_npc(i):
            continue
        id = i.get_instance_id()
        if not _actor_states.erase(id):
            push_error("Actor not found: %s." % [i.name])


func _get_actor_state(sprite: Sprite2D) -> ActorState:
    if not _is_npc(sprite):
        return

    var id: int = sprite.get_instance_id()

    if _actor_states.has(id):
        return _actor_states[id]
    push_error("Actor not found: %s." % [sprite.name])
    return null


func _is_npc(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(MainTag.ACTOR) and \
            (not sprite.is_in_group(SubTag.PC))


func _approach_pc(map_2d: Dictionary, sprite: Sprite2D, end_point: Array) \
        -> void:
    var npc_coord: Vector2i = ConvertCoord.get_coord(sprite)
    var target_coords: Array
    var move_to: Vector2i
    var trap: Sprite2D

    DijkstraPathfinding.set_obstacle_map(map_2d, _is_obstacle, [])
    DijkstraPathfinding.set_destination(map_2d, end_point)
    DijkstraPathfinding.set_distance_map(map_2d, end_point)

    target_coords = DijkstraPathfinding.get_coords(map_2d, npc_coord, 1)
    if target_coords.is_empty():
        return

    if target_coords.size() > 1:
        ArrayHelper.shuffle(target_coords, _ref_RandomNumber)
    move_to = target_coords[0]
    SpriteState.move_sprite(sprite, move_to)

    trap = SpriteState.get_trap_by_coord(move_to)
    if trap != null:
        SpriteFactory.remove_sprite(trap)


func _is_obstacle(coord: Vector2i, _opt_args: Array) -> bool:
    return SpriteState.has_building_at_coord(coord) or \
            SpriteState.has_actor_at_coord(coord)
