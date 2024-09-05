class_name PcAction
extends Node2D


signal ui_force_updated()


enum {
    NORMAL_MODE,
}


var _ref_ActorAction: ActorAction
var _ref_GameProgress: GameProgress

@onready var _ref_PcFov: PcFov = $PcFov


var _pc: Sprite2D
var _game_mode: int = NORMAL_MODE


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    if _pc != null:
        return

    for i: TaggedSprite in tagged_sprites:
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
            return


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return
    _ref_PcFov.render_fov(_pc)


func _on_PlayerInput_action_pressed(input_tag: StringName) -> void:
    var coord: Vector2i

    match input_tag:
        InputTag.MOVE_LEFT:
            coord = Vector2i.LEFT
        InputTag.MOVE_RIGHT:
            coord = Vector2i.RIGHT
        InputTag.MOVE_UP:
            coord = Vector2i.UP
        InputTag.MOVE_DOWN:
            coord = Vector2i.DOWN
        _:
            return

    coord += ConvertCoord.get_coord(_pc)
    match _game_mode:
        NORMAL_MODE:
            if not DungeonSize.is_in_dungeon(coord):
                return
            elif SpriteState.has_building_at_coord(coord):
                return
            _move(_pc, coord)
            _end_turn()
            return


func _on_GameProgress_game_over(player_win: bool) -> void:
    _ref_PcFov.render_fov(_pc)
    if not player_win:
        VisualEffect.set_dark_color(_pc)


func _move(pc: Sprite2D, coord: Vector2i) -> void:
    SpriteState.move_sprite(pc, coord)


func _is_impassable(coord: Vector2i) -> bool:
    if not DungeonSize.is_in_dungeon(coord):
        return true
    elif SpriteState.has_building_at_coord(coord):
        return true
    elif SpriteState.has_actor_at_coord(coord):
        return true
    return false


func _end_turn() -> void:
    ScheduleHelper.start_next_turn()
