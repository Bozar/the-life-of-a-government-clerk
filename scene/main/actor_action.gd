class_name ActorAction
extends Node2D


var _actor_states: Dictionary = {}
# var _map_2d: Dictionary = Map2D.init_map(DijkstraPathfinding.UNKNOWN)


func get_actor_state(sprite: Sprite2D) -> ActorState:
    if not _is_npc(sprite):
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


func _on_SignalHub_turn_started(sprite: Sprite2D) -> void:
    var actor_state: ActorState = get_actor_state(sprite)
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

        SubTag.EMPTY_CART:
            HandleEmptyCart.update_duration(actor_state)

    NodeHub.ref_Schedule.start_next_turn()


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
    var id: int
    var new_state: ActorState

    for i: TaggedSprite in tagged_sprites:
        if i.main_tag != MainTag.ACTOR:
            continue
        elif i.sub_tag == SubTag.PC:
            continue

        id = i.sprite.get_instance_id()
        match i.sub_tag:
            SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA, \
                    SubTag.FIELD_REPORT:
                new_state = RawFileState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state
                NodeHub.ref_DataHub.set_raw_file_states(new_state)

            SubTag.CLERK:
                new_state = ClerkState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state
                NodeHub.ref_DataHub.set_clerk_states(new_state)

            SubTag.OFFICER:
                new_state = OfficerState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state
                NodeHub.ref_DataHub.set_officer_states(new_state)

            SubTag.SERVANT:
                new_state = ServantState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state

            SubTag.SHELF:
                new_state = ShelfState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state
                NodeHub.ref_DataHub.set_shelf_states(new_state)

            SubTag.SALARY, SubTag.GARAGE, SubTag.STATION:
                new_state = ActorState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state

            SubTag.EMPTY_CART:
                new_state = EmptyCartState.new(i.sprite, i.sub_tag)
                _actor_states[id] = new_state

            _:
                _actor_states[id] = ActorState.new(i.sprite, i.sub_tag)


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
    var id: int

    for i: Sprite2D in sprites:
        if not _is_npc(i):
            continue
        id = i.get_instance_id()
        if not _actor_states.erase(id):
            push_error("Actor not found: %s." % [i.name])


func _is_npc(sprite: Sprite2D) -> bool:
    return sprite.is_in_group(MainTag.ACTOR) \
            and (not sprite.is_in_group(SubTag.PC))


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

