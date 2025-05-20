class_name RawFileState
extends ActorState


const INVALID_COORD: Vector2i = Vector2i(-1, -1)


var cooldown: int = 0:
	get:
		return _cooldown
	set(value):
		_cooldown = min(max(0, value), max_cooldown)

		if _cooldown > 0:
			_create_progress_bar()
		else:
			if sub_tag == SubTag.ENCYCLOPEDIA:
				_set_encyclopedia_cooldown()
			else:
				_remove_progress_bar()


var max_cooldown: int = 1:
	set(value):
		max_cooldown = max(1, value)


var send_counter: int = 0:
	set(value):
		send_counter = max(0, value)


var progress_bar_coord: Vector2i = _progress_bar_coord:
	get:
		_set_progress_bar_coord()
		return _progress_bar_coord


var _cooldown: int = 0
var _progress_bar_coord: Vector2i = INVALID_COORD


func reset_progress_bar_coord() -> void:
	_progress_bar_coord = INVALID_COORD


func _set_encyclopedia_cooldown() -> void:
	var count_cart: int = Cart.count_cart(
			NodeHub.ref_DataHub.linked_cart_state
	)

	if count_cart < GameData.CART_LENGTH_LONG:
		_create_progress_bar()
	else:
		_remove_progress_bar()


func _set_progress_bar_coord() -> void:
	if _progress_bar_coord != INVALID_COORD:
		return

	var sprite_coord: Vector2i = ConvertCoord.get_coord(sprite)

	# It is guaranteed by game design that there is exactly one building to
	# the left or right of a raw file sprite.
	for i: Vector2i in [
			sprite_coord + Vector2i.LEFT,
			sprite_coord + Vector2i.RIGHT
			]:
		if DungeonSize.is_in_dungeon(i) \
				and SpriteState.has_building_at_coord(i):
			_progress_bar_coord = i
			return
	push_error("%s at [%s, %s] has no progress bar." \
			% [sprite.name, sprite_coord.x, sprite_coord.y]
	)


func _create_progress_bar() -> void:
	if SpriteState.has_trap_at_coord(progress_bar_coord):
		return
	SpriteFactory.create_trap(SubTag.PROGRESS_BAR, progress_bar_coord, true)


func _remove_progress_bar() -> void:
	var trap: Sprite2D = SpriteState.get_trap_by_coord(progress_bar_coord)

	if trap == null:
		return
	SpriteFactory.remove_sprite(trap)

