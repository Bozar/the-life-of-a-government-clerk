class_name ActorAction
extends Node2D


# var _map_2d: Dictionary = Map2D.init_map(DijkstraPathfinding.UNKNOWN)


func _on_SignalHub_turn_started(actor: Sprite2D) -> void:
	var actor_state: ActorState = NodeHub.ref_DataHub.get_actor_state(actor)
	var sub_tag: StringName = SpriteState.get_sub_tag(actor)

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
	for i: TaggedSprite in tagged_sprites:
		if i.main_tag != MainTag.ACTOR:
			continue
		elif i.sub_tag == SubTag.PC:
			continue
		_create_actor_state(i.sub_tag, i.sprite)


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
	for i: Sprite2D in sprites:
		if not i.is_in_group(MainTag.ACTOR):
			continue
		elif i.is_in_group(SubTag.PC):
			continue

		if not NodeHub.ref_DataHub.remove_actor_state(i):
			push_error("Actor not found: %s." % [i.name])


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
	return (
			SpriteState.has_building_at_coord(coord)
			or SpriteState.has_actor_at_coord(coord)
	)


func _create_actor_state(sub_tag: StringName, sprite: Sprite2D) -> void:
	var new_state: ActorState

	match sub_tag:
		SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA, \
				SubTag.FIELD_REPORT:
			new_state = RawFileState.new(sprite, sub_tag)
			NodeHub.ref_DataHub.set_raw_file_states(new_state)

		SubTag.CLERK:
			new_state = ClerkState.new(sprite, sub_tag)
			NodeHub.ref_DataHub.set_clerk_states(new_state)

		SubTag.OFFICER:
			new_state = OfficerState.new(sprite, sub_tag)
			NodeHub.ref_DataHub.set_officer_states(new_state)

		SubTag.SERVANT:
			new_state = ServantState.new(sprite, sub_tag)

		SubTag.SHELF:
			new_state = ShelfState.new(sprite, sub_tag)
			NodeHub.ref_DataHub.set_shelf_states(new_state)

		SubTag.SALARY, SubTag.GARAGE, SubTag.STATION:
			new_state = ActorState.new(sprite, sub_tag)

		SubTag.EMPTY_CART:
			new_state = EmptyCartState.new(sprite, sub_tag)

		_:
			new_state = ActorState.new(sprite, sub_tag)

	NodeHub.ref_DataHub.set_actor_state(sprite, new_state)

