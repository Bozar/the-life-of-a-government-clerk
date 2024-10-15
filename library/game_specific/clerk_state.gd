class_name ClerkState
extends ActorState


var desk_states: Array:
    get:
        if _desk_states.is_empty():
            _init_desk_states()
        return _desk_states


var progress: int = 0:
    set(value):
        progress = value

        var visual_tag: StringName = VisualTag.DEFAULT

        if has_document:
            visual_tag = VisualTag.ACTIVE
        VisualEffect.switch_sprite(_sprite, visual_tag)


var has_empty_desk: bool:
    get:
        var state: DeskState

        for i in range(0, desk_states.size()):
            state = desk_states[i]
            if state == null:
                push_warning("desk_states[%s] is null." % i)
                return false
            elif state.sprite == null:
                return true
        return false


var has_document: bool:
    get:
        return (progress >= GameData.MAX_CLERK_PROGRESS) and has_empty_desk


var _desk_states: Array


func _init_desk_states() -> void:
    var self_coord: Vector2i = ConvertCoord.get_coord(_sprite)
    var desk_coord: Vector2i
    var distance: int

    _desk_states = [null, null]

    for i in SpriteState.get_sprites_by_sub_tag(SubTag.DESK):
        desk_coord = ConvertCoord.get_coord(i)
        distance = ConvertCoord.get_range(self_coord, desk_coord)
        # It is guaranteed by game design that there are exactly two nearby
        # sprites.
        match distance:
            1, 2:
                _desk_states[distance - 1] = DeskState.new(desk_coord)
