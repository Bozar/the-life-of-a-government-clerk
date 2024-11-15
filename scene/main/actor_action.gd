class_name ActorAction
extends Node2D


var _pc: Sprite2D
var _actor_states: Dictionary = {}
var _raw_file_states: Array
var _officer_states: Array
var _clerk_states: Array

# var _map_2d: Dictionary = Map2D.init_map(DijkstraPathfinding.UNKNOWN)


func can_receive_document(sprite: Sprite2D) -> bool:
    var state: OfficerState = _get_actor_state(sprite)
    return HandleOfficer.can_receive_document(state)


func receive_document() -> void:
    HandleRawFile.reset_cooldown(_raw_file_states)
    HandleOfficer.set_active(_officer_states, NodeHub.ref_RandomNumber)


func raw_file_is_available(sprite: Sprite2D) -> bool:
    var state: RawFileState = _get_actor_state(sprite)
    return state.cooldown < 1


func send_raw_file(sprite: Sprite2D) -> void:
    var state: RawFileState = _get_actor_state(sprite)
    var servant_cooldown: int = HandleServant.get_servant_cooldown(
            _get_actor_states(SubTag.SERVANT))

    HandleRawFile.send_raw_file(state, NodeHub.ref_RandomNumber,
            servant_cooldown)


func send_document(sprite: Sprite2D) -> bool:
    var state: ClerkState = _get_actor_state(sprite)
    return HandleClerk.send_document(state)


func receive_raw_file(sprite: Sprite2D, item_tag: StringName) -> bool:
    var state: ClerkState = _get_actor_state(sprite)

    if HandleClerk.receive_raw_file(state, item_tag):
        return true
    return false


func can_receive_servant(sprite: Sprite2D) -> bool:
    var state: RawFileState = _get_actor_state(sprite)
    return HandleRawFile.can_receive_servant(state)


func receive_servant(sprite: Sprite2D) -> void:
    var state: RawFileState = _get_actor_state(sprite)
    HandleRawFile.receive_servant(state)


func push_servant(actor: Sprite2D) -> void:
    var state: ActorState = _get_actor_state(actor)

    HandleRawFile.reduce_cooldown(_raw_file_states, NodeHub.ref_RandomNumber)
    HandleClerk.reduce_progress(_clerk_states, NodeHub.ref_RandomNumber)
    HandleServant.reset_idle_duration(state)


func switch_examine_mode(is_examine: bool) -> void:
    HandleClerk.switch_examine_mode(is_examine, _clerk_states)
    HandleRawFile.switch_examine_mode(is_examine, _raw_file_states)
    HandleServant.switch_examine_mode(is_examine,
            _get_actor_states(SubTag.SERVANT))


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    var actor_state: ActorState = _get_actor_state(sprite)
    var sub_tag: StringName = SpriteState.get_sub_tag(sprite)

    if actor_state == null:
        return

    match sub_tag:
        SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
            HandleRawFile.update_cooldown(actor_state)
        SubTag.CLERK:
            HandleClerk.update_progress(actor_state)
        SubTag.SERVANT:
            HandleServant.update_idle_duration(actor_state)
    NodeHub.ref_Schedule.start_next_turn()


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    var id: int
    var new_state: ActorState

    for i: TaggedSprite in tagged_sprites:
        if not i.main_tag == MainTag.ACTOR:
            continue
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
        else:
            id = i.sprite.get_instance_id()
            match i.sub_tag:
                SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
                    new_state = RawFileState.new(i.sprite, i.sub_tag)
                    _actor_states[id] = new_state
                    _raw_file_states.push_back(new_state)
                SubTag.CLERK:
                    new_state = ClerkState.new(i.sprite, i.sub_tag)
                    _actor_states[id] = new_state
                    _clerk_states.push_back(new_state)
                SubTag.OFFICER:
                    new_state = OfficerState.new(i.sprite, i.sub_tag)
                    _actor_states[id] = new_state
                    _officer_states.push_back(new_state)
                SubTag.SERVANT:
                    new_state = ServantState.new(i.sprite, i.sub_tag)
                    _actor_states[id] = new_state
                    new_state.max_idle_duration \
                            = NodeHub.ref_RandomNumber.get_int(
                            GameData.MIN_IDLE_DURATION,
                            GameData.MAX_IDLE_DURATION + 1)
                _:
                    _actor_states[id] = ActorState.new(i.sprite, i.sub_tag)


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
        return null

    var id: int = sprite.get_instance_id()

    if _actor_states.has(id):
        return _actor_states[id]
    push_error("Actor not found: %s." % [sprite.name])
    return null


func _is_npc(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(MainTag.ACTOR) \
            and (not sprite.is_in_group(SubTag.PC))


func _get_actor_states(sub_tag: StringName) -> Array:
    var state: ActorState
    var states: Array

    for i in SpriteState.get_sprites_by_sub_tag(sub_tag):
        state = _get_actor_state(i)
        if state != null:
            states.push_back(state)
    return states


func _approach_pc(
        map_2d: Dictionary, sprite: Sprite2D, end_point: Array
        ) -> void:
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
        ArrayHelper.shuffle(target_coords, NodeHub.ref_RandomNumber)
    move_to = target_coords[0]
    SpriteState.move_sprite(sprite, move_to)

    trap = SpriteState.get_trap_by_coord(move_to)
    if trap != null:
        SpriteFactory.remove_sprite(trap)


func _is_obstacle(coord: Vector2i, _opt_args: Array) -> bool:
    return SpriteState.has_building_at_coord(coord) \
            or SpriteState.has_actor_at_coord(coord)
